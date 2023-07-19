//
//  SICDetailsViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 31.05.2023.
//

import RxSwift
import RxCocoa

final class SICDetailsViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var details = makeDetails()
    private let id: Driver<Int>
    
    private lazy var symptomsManager = SymptomsManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(id: Int) {
        self.id = BehaviorRelay(value: id).asDriver()
    }
}

// MARK: Public
extension SICDetailsViewModel {
    struct Input {
        let didTapMark: Signal<Bool>
        let didTapFilter: Signal<SICDetailsFilterView.Filter>
    }
    
    struct Output {
        let marked: Driver<Bool>
        let sections: Driver<[SICDetailsTableSection]>
        let name: Driver<String>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            marked: makeBookmark(didTapMark: input.didTapMark),
            sections: makeSections(didTapFilter: input.didTapFilter),
            name: makeName(),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension SICDetailsViewModel {
    func makeBookmark(didTapMark: Signal<Bool>) -> Driver<Bool> {
        let initial = details
            .map { $0.saved }
        
        let action = didTapMark
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(details) {  ($0, $1) }
            .flatMapLatest { [weak self] saved, details -> Driver<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Void> {
                    saved ? self.symptomsManager.unsave(conditionsIds: [details.id]) : self.symptomsManager.save(conditionId: details.id)
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
    
    func makeSections(didTapFilter: Signal<SICDetailsFilterView.Filter>) -> Driver<[SICDetailsTableSection]> {
        Driver
            .combineLatest(
                didTapFilter
                    .asDriver(onErrorDriveWith: .never())
                    .startWith(.conditionDetails),
                makeConditionDetailsSections(),
                makeTreatmentOptionsSections()
            )
            .map { filter, conditionsDetails, treatmentOptions -> [SICDetailsTableSection] in
                switch filter {
                case .treatmentOptions:
                    return treatmentOptions
                case .conditionDetails:
                    return conditionsDetails
                }
            }
    }
    
    func makeConditionDetailsSections() -> Driver<[SICDetailsTableSection]> {
        details
            .map { [weak self] details -> [SICDetailsTableSection] in
                guard let self = self else {
                    return []
                }
                
                return self.buildSections(from: details.details)
            }
    }
    
    func makeTreatmentOptionsSections() -> Driver<[SICDetailsTableSection]> {
        details
            .map { [weak self] details -> [SICDetailsTableSection] in
                guard let self = self else {
                    return []
                }
                
                return self.buildSections(from: details.treatmentOptions)
            }
    }
    
    func makeName() -> Driver<String> {
        details
            .map { $0.name }
    }
    
    func makeDetails() -> Driver<SymptomsInteractionConditionDetails> {
        id
            .flatMapLatest { [weak self] id -> Driver<SymptomsInteractionConditionDetails> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<SymptomsInteractionConditionDetails> {
                    self.symptomsManager
                        .obtainConditionDetails(id: id)
                        .flatMap { details -> Single<SymptomsInteractionConditionDetails> in
                            guard let details = details else {
                                return .error(ContentError(.notContent))
                            }
                            
                            return .just(details)
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

// MARK: Private (Additional)
private extension SICDetailsViewModel {
//    func buildSections(from blocks: [DrugBlock]) -> [SICDetailsTableSection] {
//        blocks
//            .enumerated()
//            .compactMap { index, block -> SICDetailsTableSection? in
//                let isLast = (blocks.count - 1) == index
//
//                guard let title = block.title else {
//                    return nil
//                }
//
//                let sectionElement = SICDetailsSectionElement(name: title, opened: false)
//
//                var openedElements: [SICDetailsTableElement] = [
//                    .section(sectionElement),
//                    .text(block.text)
//                ]
//                if !isLast {
//                    openedElements.append(.separator)
//                }
//
//                return SICDetailsTableSection(
//                    opened: false,
//                    openedElements: openedElements,
//                    closedElements: [.section(sectionElement), isLast ? nil : .separator].compactMap { $0 }
//                )
//            }
//    }
    
    func buildSections(from sections: [SymptomsCheckerSection]) -> [SICDetailsTableSection] {
        sections
            .enumerated()
            .compactMap { index, section -> SICDetailsTableSection? in
                let isLast = (sections.count - 1) == index
                
                let sectionElement = SICDetailsSectionElement(name: section.name, opened: false)
                
                var openedElements: [SICDetailsTableElement] = [
                    .section(sectionElement)
                ]
                section.blocks.forEach { block in
                    guard case let .text(text) = block else {
                        return
                    }
                    
                    openedElements.append(.text(text))
                }
                if !isLast {
                    openedElements.append(.separator)
                }
                
                return SICDetailsTableSection(
                    opened: false,
                    openedElements: openedElements,
                    closedElements: [.section(sectionElement), isLast ? nil : .separator].compactMap { $0 }
                )
            }
    }
}
