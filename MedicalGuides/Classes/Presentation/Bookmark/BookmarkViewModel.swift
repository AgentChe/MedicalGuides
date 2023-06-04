//
//  BookmarkViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import RxSwift
import RxCocoa

final class BookmarkViewModel {
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var bookmarkDrugs = makeBookmarkDrugs()
    private lazy var interactions = makeInteractions()
    private lazy var conditions = makeConditions()
    private lazy var drugs = makeDrugs()
    
    private lazy var symptomsManager = SymptomsManager()
    private lazy var drugsManager = DrugsManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension BookmarkViewModel {
    struct Input {
        let didTapFilter: Signal<BookmarkFilterView.Filter>
        let didTapDone: Signal<Void>
        let didTapEdit: Signal<Void>
        let didTapDelete: Signal<Void>
        let didTapDrug: Signal<Drug>
        let didTapInteraction: Signal<DrugsInteraction>
        let didTapCondition: Signal<SymptomsInteractionConditionDetails>
    }
    
    struct Output {
        let navigationMode: Driver<BookmarkViewController.NavigationMode>
        let elements: Driver<[BookmarkTableElement]>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            navigationMode: makeNavigationMode(
                didTapDone: input.didTapDone,
                didTapEdit: input.didTapEdit,
                didTapDelete: input.didTapDelete
            ),
            elements: makeElements(didTapFilter: input.didTapFilter),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension BookmarkViewModel {
    func makeNavigationMode(
        didTapDone: Signal<Void>,
        didTapEdit: Signal<Void>,
        didTapDelete: Signal<Void>
    ) -> Driver<BookmarkViewController.NavigationMode> {
        Signal<BookmarkViewController.NavigationMode>
            .merge(
                didTapDone.map { .normal },
                didTapEdit.map { .editable },
                didTapDelete.map { .normal }
            )
            .startWith(.normal)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeElements(didTapFilter: Signal<BookmarkFilterView.Filter>) -> Driver<[BookmarkTableElement]> {
        Driver
            .combineLatest(
                didTapFilter.asDriver(onErrorDriveWith: .never()),
                bookmarkDrugs,
                interactions,
                conditions,
                drugs
            )
            .map { filter, bookmarkDrugs, interactions, conditions, drugs -> [BookmarkTableElement] in
                switch filter {
                case .drugs:
                    return bookmarkDrugs.map { .init(unit: .drug($0), seleted: nil) }
                case .interactions:
                    return interactions.map { interaction -> BookmarkTableElement in
                        // TODO
//                        let element = BookmarkInteractionElement(
//                            interaction: interaction,
//                            drugs: drugs.filter { drug -> Bool in
//                                interaction.drugsIds.contains(where: { $0 == drug.id })
//                            }
//                        )
                        let element = BookmarkInteractionElement(
                            interaction: interaction,
                            drugs: Array(drugs.prefix(Int.random(in: 1...5)))
                        )
                        return BookmarkTableElement(unit: .interaction(element), seleted: nil)
                    }
                case .conditions:
                    return conditions.map { .init(unit: .condition($0), seleted: nil) }
                }
            }
    }
    
    func makeBookmarkDrugs() -> Driver<[Drug]> {
        makeUnits(
            downloadTrigger: DrugsMediator.shared
                .didSaveDrugId
                .map { id in Void() },
            removeTrigger: DrugsMediator.shared
                .didUnsaveDrugsIds,
            source: { [weak self] in
                guard let self = self else {
                    return .never()
                }
                
                return self.drugsManager
                    .obtainBookmarksDrugs()
            },
            remove: { ids, drug -> Bool in
                ids.contains(where: { $0 == drug.id })
            }
        )
    }
    
    func makeInteractions() -> Driver<[DrugsInteraction]> {
        makeUnits(
            downloadTrigger: DrugsMediator.shared
                .didSaveInteractionId
                .map { id in Void() },
            removeTrigger: DrugsMediator.shared
                .didUnsaveInteractionsIds,
            source: { [weak self] in
                guard let self = self else {
                    return .never()
                }
                
                return self.drugsManager
                    .obtainBookmarksInteractions()
            },
            remove: { ids, interaction -> Bool in
                ids.contains(where: { $0 == interaction.id })
            }
        )
    }
    
    func makeConditions() -> Driver<[SymptomsInteractionConditionDetails]> {
        makeUnits(
            downloadTrigger: SymptomsMediator.shared
                .didSaveConditionId
                .map { id in Void() },
            removeTrigger: SymptomsMediator.shared
                .didUnsaveConditionsIds,
            source: { [weak self] in
                guard let self = self else {
                    return .never()
                }
                
                return self.symptomsManager
                    .obtainBookmarksConditions()
            },
            remove: { ids, condition -> Bool in
                ids.contains(where: { $0 == condition.id })
            }
        )
    }
    
    func makeUnits<T>(
        downloadTrigger: Signal<Void>,
        removeTrigger: Signal<[Int]>,
        source: @escaping () -> Single<[T]>,
        remove: @escaping ([Int], T) -> Bool
    ) -> Driver<[T]> {
        let download = downloadTrigger
            .map { id in Void() }
            .startWith(Void())
            .flatMapLatest { [weak self] void -> Driver<[T]> in
                guard let self = self else {
                    return .never()
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
        
        return download
            .flatMapLatest { units -> Driver<[T]> in
                removeTrigger
                    .startWith([])
                    .asDriver(onErrorJustReturn: [])
                    .scan(units) { array, ids -> [T] in
                        guard !ids.isEmpty else {
                            return array
                        }
                        
                        var result = array
                        result.removeAll(where: { t -> Bool in
                            remove(ids, t)
                        })
                        
                        return result
                    }
            }
    }
    
    func makeDrugs() -> Driver<[Drug]> {
        drugsManager
            .obtainDrugs(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
}
