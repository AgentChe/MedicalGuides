//
//  DrugViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import RxSwift
import RxCocoa

final class DrugViewModel {
    enum Route {
        case paygate
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var drug = makeDrug()
    private let id: Driver<Int>
    private lazy var needPaygateTrigger = PublishRelay<Void>()
    
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
        let route: Driver<Route>
        let disposable: Disposable
    }
    
    func configure(input: Input) -> Output {
        let activeSubscription = makeActiveSubscription()
        let bookmarkDrugs = makeBookmarkDrugs()
        let canSave = makeCanSave(
            bookmarkDrugs: bookmarkDrugs,
            activeSubscription: activeSubscription
        )
        
        return Output(
            marked: makeBookmark(
                didTapMark: input.didTapMark,
                canSave: canSave
            ),
            sections: makeSections(),
            activity: activity.asDriver(),
            route: makeRoute(),
            disposable: canSave.drive()
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
    
    func makeBookmark(
        didTapMark: Signal<Bool>,
        canSave: Driver<Bool>
    ) -> Driver<Bool> {
        let initial = drug
            .map { $0.saved }
        
        let action = didTapMark
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(canSave) { ($0, $1) }
            .withLatestFrom(drug) {  ($0.0, $0.1, $1) }
            .flatMapLatest { [weak self] saved, canSave, drug -> Driver<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                if !saved && !canSave {
                    self.needPaygateTrigger.accept(Void())
                    return .just(saved)
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
    
    func makeRoute() -> Driver<Route> {
        needPaygateTrigger
            .map { Route.paygate }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeCanSave(
        bookmarkDrugs: Driver<[Drug]>,
        activeSubscription: Driver<Bool>
    ) -> Driver<Bool> {
        activeSubscription
            .flatMapLatest { activeSubscription -> Driver<Bool> in
                guard !activeSubscription else {
                    return .just(true)
                }
                
                return bookmarkDrugs
                    .map { $0.count < 1 }
            }
    }
    
    func makeBookmarkDrugs() -> Driver<[Drug]> {
        Driver
            .merge(
                DrugsMediator.shared.didSaveDrugId
                    .map { id in Void() }
                    .asDriver(onErrorDriveWith: .never()),
                DrugsMediator.shared.didUnsaveDrugsIds
                    .map { ids in Void() }
                    .asDriver(onErrorDriveWith: .never())
            )
            .startWith(Void())
            .flatMapLatest { [weak self] void -> Driver<[Drug]> in
                guard let self = self else {
                    return .never()
                }
                
                return self.drugsManager
                    .obtainBookmarksDrugs()
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .map { SessionManager().hasActiveSubscriptions() }
            .startWith(SessionManager().hasActiveSubscriptions())
            .asDriver(onErrorJustReturn: false)
    }
}
