//
//  BookmarkViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import RxSwift
import RxCocoa

final class BookmarkViewModel {
    enum Route {
        case drug(Drug)
        case interaction(DrugsInteraction)
        case condition(SymptomsInteractionConditionDetails)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var bookmarkDrugs = makeBookmarkDrugs()
    private lazy var interactions = makeInteractions()
    private lazy var conditions = makeConditions()
    private lazy var drugs = makeDrugs()
    private lazy var interactionCheckerMeds = makeInteractionCheckerMeds()
    
    private lazy var didDeleteTrigger = PublishRelay<Bool>()
    
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
        let isEmpty: Driver<BookmarkEmptyView.Unit?>
        let navigationMode: Driver<BookmarkViewController.NavigationMode>
        let elements: Driver<[BookmarkTableElement]>
        let activity: Driver<Bool>
        let hasSelectedOnCurrentFilter: Driver<Bool>
        let route: Driver<Route>
        let disposable: Disposable
    }
    
    func configure(input: Input) -> Output {
        let didTapFilter = input
            .didTapFilter
            .startWith(.drugs)
            .asDriver(onErrorDriveWith: .never())
        let navigationMode = makeNavigationMode(
            didTapDone: input.didTapDone,
            didTapEdit: input.didTapEdit,
            didDelete: didDeleteTrigger.asSignal()
        )
        let selectedDrugs = makeSelectedDrugs(
            navigationMode: navigationMode,
            didTapDrug: input.didTapDrug
        )
        let selectedInteractions = makeSelectedInteractions(
            navigationMode: navigationMode,
            didTapInteraction: input.didTapInteraction
        )
        let selectedConditions = makeSelectedConditions(
            navigationMode: navigationMode,
            didTapCondition: input.didTapCondition
        )
        let drugsElements = makeDrugsElements(
            navigationMode: navigationMode,
            selectedDrugs: selectedDrugs
        )
        let interactionsElements = makeInteractionsElements(
            navigationMode: navigationMode,
            selectedInteractions: selectedInteractions
        )
        let conditionsElements = makeConditionsElements(
            navigationMode: navigationMode,
            selectedConditions: selectedConditions
        )
        let route = makeRoute(
            navigationMode: navigationMode,
            didTapDrug: input.didTapDrug,
            didTapInteraction: input.didTapInteraction,
            didTapCondition: input.didTapCondition
        )
        let didDelete = makeDelete(
            didTapFilter: didTapFilter,
            didTapDelete: input.didTapDelete,
            selectedDrugs: selectedDrugs,
            selectedInteractions: selectedInteractions,
            selectedConditions: selectedConditions
        )
        let disposable = didDelete
            .asSignal(onErrorSignalWith: .never())
            .emit(to: didDeleteTrigger)
        
        return Output(
            isEmpty: makeIsEmpty(
                didTapFilter: didTapFilter,
                drugsElements: drugsElements,
                interactionsElements: interactionsElements,
                conditionsElements: conditionsElements
            ),
            navigationMode: navigationMode,
            elements: makeElements(
                didTapFilter: didTapFilter,
                drugsElements: drugsElements,
                interactionsElements: interactionsElements,
                conditionsElements: conditionsElements
            ),
            activity: activity.asDriver(),
            hasSelectedOnCurrentFilter: makeHasSelectedOnCurrentFilter(
                didTapFilter: didTapFilter,
                selectedDrugs: selectedDrugs,
                selectedInteractions: selectedInteractions,
                selectedConditions: selectedConditions
            ),
            route: route,
            disposable: disposable
        )
    }
}

// MARK: Private
private extension BookmarkViewModel {
    enum DeleteAction {
        case drugs([Int])
        case interactions([Int])
        case conditions([Int])
    }
    
    func makeIsEmpty(
        didTapFilter: Driver<BookmarkFilterView.Filter>,
        drugsElements: Driver<[BookmarkTableElement]>,
        interactionsElements: Driver<[BookmarkTableElement]>,
        conditionsElements: Driver<[BookmarkTableElement]>
    ) -> Driver<BookmarkEmptyView.Unit?> {
        Driver
            .combineLatest(
                didTapFilter,
                drugsElements,
                interactionsElements,
                conditionsElements
            ).map { filter, drugs, interactions, conditions -> BookmarkEmptyView.Unit? in
                switch filter {
                case .drugs:
                    return drugs.isEmpty ? .drugs : nil
                case .interactions:
                    return interactions.isEmpty ? .interactions : nil
                case .conditions:
                    return conditions.isEmpty ? .conditions : nil
                }
            }
    }
    
    func makeNavigationMode(
        didTapDone: Signal<Void>,
        didTapEdit: Signal<Void>,
        didDelete: Signal<Bool>
    ) -> Driver<BookmarkViewController.NavigationMode> {
        Signal<BookmarkViewController.NavigationMode>
            .merge(
                didTapDone.map { .normal },
                didTapEdit.map { .editable },
                didDelete.flatMapLatest { success in
                    success ? .just(.normal) : .never()
                }
            )
            .startWith(.normal)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeElements(
        didTapFilter: Driver<BookmarkFilterView.Filter>,
        drugsElements: Driver<[BookmarkTableElement]>,
        interactionsElements: Driver<[BookmarkTableElement]>,
        conditionsElements: Driver<[BookmarkTableElement]>
    ) -> Driver<[BookmarkTableElement]> {
        Driver
            .combineLatest(
                didTapFilter,
                drugsElements,
                interactionsElements,
                conditionsElements
            )
            .map { filter, drugs, interactions, conditions -> [BookmarkTableElement] in
                switch filter {
                case .drugs:
                    return drugs
                case .interactions:
                    return interactions
                case .conditions:
                    return conditions
                }
            }
    }
    
    func makeHasSelectedOnCurrentFilter(
        didTapFilter: Driver<BookmarkFilterView.Filter>,
        selectedDrugs: Driver<[Drug]>,
        selectedInteractions: Driver<[DrugsInteraction]>,
        selectedConditions: Driver<[SymptomsInteractionConditionDetails]>
    ) -> Driver<Bool> {
        Driver
            .combineLatest(
                didTapFilter,
                selectedDrugs.startWith([]),
                selectedInteractions.startWith([]),
                selectedConditions.startWith([])
            )
            .map { filter, drugs, interactions, conditions -> Bool in
                switch filter {
                case .drugs:
                    return !drugs.isEmpty
                case .interactions:
                    return !interactions.isEmpty
                case .conditions:
                    return !conditions.isEmpty
                }
            }
    }
    
    func makeDrugsElements(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        selectedDrugs: Driver<[Drug]>
    ) -> Driver<[BookmarkTableElement]> {
        Driver
            .combineLatest(
                navigationMode,
                bookmarkDrugs,
                selectedDrugs
            )
            .map { mode, bookmarkDrugs, selectedDrugs -> [BookmarkTableElement] in
                bookmarkDrugs.map { drug -> BookmarkTableElement in
                    BookmarkTableElement(
                        unit: .drug(drug),
                        seleted: mode == .editable ? selectedDrugs.contains(where: { $0.id == drug.id }) : nil
                    )
                }
            }
    }
    
    func makeInteractionsElements(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        selectedInteractions: Driver<[DrugsInteraction]>
    ) -> Driver<[BookmarkTableElement]> {
        Driver
            .combineLatest(
                navigationMode,
                interactions,
                selectedInteractions,
                interactionCheckerMeds
            )
            .map { mode, interactions, selectedInteractions, meds -> [BookmarkTableElement] in
                interactions.map { interaction -> BookmarkTableElement in
                    let element = BookmarkInteractionElement(
                        interaction: interaction,
                        meds: meds.filter { med -> Bool in
                            interaction.medIds.contains(where: { $0 == med.id })
                        }
                    )
                    return BookmarkTableElement(
                        unit: .interaction(element),
                        seleted: mode == .editable ? selectedInteractions.contains(where: { $0.id == interaction.id }) : nil
                    )
                }
            }
    }
    
    func makeConditionsElements(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        selectedConditions: Driver<[SymptomsInteractionConditionDetails]>
    ) -> Driver<[BookmarkTableElement]> {
        Driver
            .combineLatest(
                navigationMode,
                conditions,
                selectedConditions
            )
            .map { mode, conditions, selectedConditions -> [BookmarkTableElement] in
                conditions.map { condition -> BookmarkTableElement in
                    BookmarkTableElement(
                        unit: .condition(condition),
                        seleted: mode == .editable ? selectedConditions.contains(where: { $0.id == condition.id }) : nil
                    )
                }
            }
    }
    
    func makeSelectedDrugs(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        didTapDrug: Signal<Drug>
    ) -> Driver<[Drug]> {
        makeSelectedUnits(
            navigationMode: navigationMode,
            didTapUnit: didTapDrug,
            index: { drug, selectedDrugs -> Int? in
                selectedDrugs.firstIndex(where: { $0.id == drug.id })
            }
        )
    }
    
    func makeSelectedInteractions(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        didTapInteraction: Signal<DrugsInteraction>
    ) -> Driver<[DrugsInteraction]> {
        makeSelectedUnits(
            navigationMode: navigationMode,
            didTapUnit: didTapInteraction,
            index: { interaction, selectedInteractions -> Int? in
                selectedInteractions.firstIndex(where: { $0.id == interaction.id })
            }
        )
    }
    
    func makeSelectedConditions(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        didTapCondition: Signal<SymptomsInteractionConditionDetails>
    ) -> Driver<[SymptomsInteractionConditionDetails]> {
        makeSelectedUnits(
            navigationMode: navigationMode,
            didTapUnit: didTapCondition,
            index: { condition, selectedConditions -> Int? in
                selectedConditions.firstIndex(where: { $0.id == condition.id })
            }
        )
    }
    
    func makeSelectedUnits<T>(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        didTapUnit: Signal<T>,
        index: @escaping ((T, [T]) -> Int?)
    ) -> Driver<[T]> {
        navigationMode
            .flatMapLatest { mode -> Driver<[T]> in
                switch mode {
                case .editable:
                    return didTapUnit
                        .scan([]) { array, unit -> [T] in
                            if let index = index(unit, array) {
                                var result = array
                                result.remove(at: index)
                                return result
                            } else {
                                return array + [unit]
                            }
                        }
                        .startWith([])
                        .asDriver(onErrorJustReturn: [])
                case .normal:
                    return .just([])
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
    
    func makeInteractionCheckerMeds() -> Driver<[InteractionCheckerMed]> {
        drugsManager
            .obtainInteractionCheckerMeds(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        didTapDrug: Signal<Drug>,
        didTapInteraction: Signal<DrugsInteraction>,
        didTapCondition: Signal<SymptomsInteractionConditionDetails>
    ) -> Driver<Route> {
        Signal<Route>
            .merge(
                didTapDrug.map { Route.drug($0) },
                didTapInteraction.map { Route.interaction($0) },
                didTapCondition.map { Route.condition($0) }
            )
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(navigationMode) { ($0, $1) }
            .compactMap { $1 == .normal ? $0 : nil }
    }
    
    func makeDelete(
        didTapFilter: Driver<BookmarkFilterView.Filter>,
        didTapDelete: Signal<Void>,
        selectedDrugs: Driver<[Drug]>,
        selectedInteractions: Driver<[DrugsInteraction]>,
        selectedConditions: Driver<[SymptomsInteractionConditionDetails]>
    ) -> Driver<Bool> {
        let filter = didTapDelete
            .withLatestFrom(didTapFilter)
            .asDriver(onErrorDriveWith: .never())

        let selected = Driver
            .combineLatest(
                selectedDrugs.startWith([]),
                selectedInteractions.startWith([]),
                selectedConditions.startWith([])
            )

        return filter
            .withLatestFrom(selected) { ($0, $1) }
            .flatMapLatest { [weak self] filter, args -> Driver<Bool> in
                guard let self = self else {
                    return .never()
                }

                let (drugs, interactions, conditions) = args

                func source() -> Single<Void> {
                    switch filter {
                    case .drugs:
                        return self.drugsManager
                            .unsave(drugsIds: drugs.map { $0.id })
                    case .interactions:
                        return self.drugsManager
                            .unsave(interactionsIds: interactions.map { $0.id })
                    case .conditions:
                        return self.symptomsManager
                            .unsave(conditionsIds: conditions.map { $0.id })
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
                    .map { true }
                    .asDriver(onErrorJustReturn: false)
            }
    }
}
