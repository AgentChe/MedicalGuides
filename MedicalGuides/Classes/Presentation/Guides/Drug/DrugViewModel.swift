//
//  DrugViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import RxSwift
import RxCocoa

final class DrugViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var drug = makeDrug()
    private let id: Driver<Int>
    
    private lazy var drugsManager = DrugsManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(id: Int) {
        self.id = BehaviorRelay(value: id).asDriver()
    }
}

// MARK: Public
extension DrugViewModel {
    struct Input {
        let didTapMark: Signal<Bool>
    }
    
    struct Output {
        let marked: Driver<Bool>
        let sections: Driver<[DrugTableSection]>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            marked: makeBookmark(didTapMark: input.didTapMark),
            sections: makeSections(),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension DrugViewModel {
    func makeSections() -> Driver<[DrugTableSection]> {
        drug
            .map { drug -> [DrugTableSection] in
                var result = [DrugTableSection]()
                
                let nameSection = DrugTableSection(
                    opened: false,
                    openedElements: [],
                    closedElements: [
                        .name(drug.name)
                    ]
                )
                result.append(nameSection)
                
                drug.sections.enumerated().forEach { index, drugSection in
                    let isLast = (drug.sections.count - 1) == index
                    
                    let sectionElement = DrugSectionElement(name: drugSection.name, opened: true)
                    
                    var openedElements: [DrugTableElement] = [.section(sectionElement)]
                    drugSection.blocks.forEach { block in
                        if let title = block.title {
                            openedElements.append(.title(title))
                        }
                        openedElements.append(.text(block.text))
                    }
                    if !isLast {
                        openedElements.append(.separator)
                    }
                    
                    let section = DrugTableSection(
                        opened: false,
                        openedElements: openedElements,
                        closedElements: [.section(sectionElement), isLast ? nil : .separator].compactMap { $0 }
                    )
                    result.append(section)
                }
                
                return result
            }
    }
    
    func makeBookmark(didTapMark: Signal<Bool>) -> Driver<Bool> {
        let initial = drug
            .map { $0.saved }
        
        let action = didTapMark
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(drug) {  ($0, $1) }
            .flatMapLatest { [weak self] saved, drug -> Driver<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Void> {
                    saved ? self.drugsManager.unsave(drugsIds: [drug.id]) : self.drugsManager.save(drugId: drug.id)
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .asDriver(onErrorDriveWith: .never())
                    .map { !saved }
            }
        
        return Driver
            .merge(initial, action)
    }
    
    func makeDrug() -> Driver<DrugDetails> {
        id
            .flatMapLatest { [weak self] id -> Driver<DrugDetails> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<DrugDetails> {
                    self.drugsManager
                        .obtainDrugDetails(id: id)
                        .flatMap { drug -> Single<DrugDetails> in
                            guard let drug = drug else {
                                return .error(ContentError(.notContent))
                            }
                            
                            return .just(drug)
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
