//
//  InteractionCheckerViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

import RxSwift
import RxCocoa

final class InteractionCheckerViewModel {
    enum Route {
        case selectDrug(forElementId: String, selectedIds: [Int])
        case paygate
        case noInteractionsFound
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var drugsManager = DrugsManager()
    private lazy var sessionManager = SessionManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension InteractionCheckerViewModel {
    struct Input {
        let didTapElement: Signal<InteractionCheckerDrugElement>
        let didTapDelete: Signal<InteractionCheckerDrugElement>
        let didTapCheck: Signal<Void>
        let didSelectDrug: Signal<(InteractionCheckerMed, String)>
        let didTapBookmark: Signal<Bool>
    }
    
    struct Output {
        let elements: Driver<[InteractionCheckerTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let action = makeAction(
            didTapDelete: input.didTapDelete,
            didSelectDrug: input.didSelectDrug
        )
        let drugsElements = makeDrugsElements(action: action)
        let selectedDrugs = makeSelectedDrugs(drugsElements: drugsElements)
        let result = makeResult(
            didTapCheck: input.didTapCheck,
            selectedDrugs: selectedDrugs
        )
        let bookmark = makeBookmark(
            didTapBookmark: input.didTapBookmark,
            interaction: result
        ).startWith(false)
        
        return Output(
            elements: makeElements(
                drugsElements: drugsElements,
                selectedDrugs: selectedDrugs,
                result: result,
                bookmark: bookmark
            ),
            route: makeRoute(
                didTapElement: input.didTapElement,
                selectedDrugs: selectedDrugs,
                didTapCheck: input.didTapCheck,
                result: result
            )
        )
    }
}

// MARK: Private
private extension InteractionCheckerViewModel {
    enum Action {
        case initial
        case deleteDrug(String)
        case select((InteractionCheckerMed, String))
    }
    
    func makeElements(
        drugsElements: Driver<[InteractionCheckerDrugElement]>,
        selectedDrugs: Driver<[InteractionCheckerMed]>,
        result: Driver<DrugsInteraction?>,
        bookmark: Driver<Bool>
    ) -> Driver<[InteractionCheckerTableElement]> {
        Driver
            .combineLatest(
                drugsElements,
                selectedDrugs,
                result.startWith(nil),
                activity.asDriver(),
                bookmark
            )
            .map { drugsElements, selectedDrugs, interaction, activity, bookmark -> [InteractionCheckerTableElement] in
                var result: [InteractionCheckerTableElement] = drugsElements.map {
                    .drug($0)
                }
                
                if activity {
                    result.append(.preloader)
                } else if selectedDrugs.count >= 2 {
                    result.append(.check)
                }
                
                if let interaction = interaction {
                    let element = InteractionCheckerResultElement(
                        result: interaction,
                        marked: bookmark
                    )
                    result.append(.result(element))
                }
                
                return result
            }
    }
    
    func makeDrugsElements(action: Driver<Action>) -> Driver<[InteractionCheckerDrugElement]> {
        action
            .startWith(.initial)
            .scan([]) { array, action -> [InteractionCheckerDrugElement] in
                var elements = array
                
                switch action {
                case .initial:
                    elements = [
                        InteractionCheckerDrugElement(
                            id: UUID().uuidString,
                            number: 1,
                            deleteEnabled: false,
                            mode: .choose
                        ),
                        InteractionCheckerDrugElement(
                            id: UUID().uuidString,
                            number: 2,
                            deleteEnabled: false,
                            mode: .choose
                        )
                    ]
                case .deleteDrug(let id):
                    elements.removeAll(where: { $0.id == id })
                case let .select((drug, forId)):
                    guard let index = elements.firstIndex(where: { $0.id == forId }) else {
                        break
                    }
                    
                    let old = elements[index]
                    
                    let new = InteractionCheckerDrugElement(
                        id: old.id,
                        number: old.number,
                        deleteEnabled: old.deleteEnabled,
                        mode: .drug(drug)
                    )
                    elements[index] = new
                }
                
                return elements
            }
    }
    
    func makeAction(
        didTapDelete: Signal<InteractionCheckerDrugElement>,
        didSelectDrug: Signal<(InteractionCheckerMed, String)>
    ) -> Driver<Action> {
        let delete = didTapDelete
            .map { Action.deleteDrug($0.id) }
            .asDriver(onErrorDriveWith: .never())
        let select = didSelectDrug
            .map { Action.select($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(delete, select)
    }
    
    func makeRoute(
        didTapElement: Signal<InteractionCheckerDrugElement>,
        selectedDrugs: Driver<[InteractionCheckerMed]>,
        didTapCheck: Signal<Void>,
        result: Driver<DrugsInteraction?>
    ) -> Driver<Route> {
        let selectDrug = makeSelectDrugRoute(
            didTapElement: didTapElement,
            selectedDrugs: selectedDrugs
        )
        let tapCheck = didTapCheck
            .filter { [weak self] void -> Bool in
                self?.sessionManager.hasActiveSubscriptions() == false
            }
            .map { Route.paygate }
            .asDriver(onErrorDriveWith: .never())
        let notInteractionResult = result
            .compactMap { result -> Route? in
                result == nil ? .noInteractionsFound : nil
            }
        
        return Driver
            .merge(selectDrug, tapCheck, notInteractionResult)
    }
    
    func makeSelectDrugRoute(
        didTapElement: Signal<InteractionCheckerDrugElement>,
        selectedDrugs: Driver<[InteractionCheckerMed]>
    ) -> Driver<Route> {
        didTapElement
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(selectedDrugs) { ($0, $1) }
            .map { element, selectedDrugs -> Route in
                Route.selectDrug(
                    forElementId: element.id,
                    selectedIds: selectedDrugs.map { $0.id }
                )
            }
    }
    
    func makeSelectedDrugs(drugsElements: Driver<[InteractionCheckerDrugElement]>) -> Driver<[InteractionCheckerMed]> {
        drugsElements.map { drugsElements -> [InteractionCheckerMed] in
            drugsElements.compactMap { element -> InteractionCheckerMed? in
                switch element.mode {
                case .drug(let drug):
                    return drug
                case .choose:
                    return nil
                }
            }
        }
    }
    
    func makeResult(
        didTapCheck: Signal<Void>,
        selectedDrugs: Driver<[InteractionCheckerMed]>
    ) -> Driver<DrugsInteraction?> {
        didTapCheck
            .filter { [weak self] void -> Bool in
                self?.sessionManager.hasActiveSubscriptions() == true
            }
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(selectedDrugs)
            .flatMapLatest { [weak self] drugs -> Driver<DrugsInteraction?> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<DrugsInteraction?> {
                    self.drugsManager
                        .interactionCheck(medIds: drugs.map { $0.id })
                        .flatMap { result -> Single<DrugsInteraction?> in
                            guard let result = result else {
                                return .error(ContentError(.notContent))
                            }
                            
                            switch result {
                            case .none:
                                return .just(nil)
                            case .interaction(let interaction):
                                return .just(interaction)
                            }
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
    
    func makeBookmark(didTapBookmark: Signal<Bool>, interaction: Driver<DrugsInteraction?>) -> Driver<Bool> {
        let initial = interaction
            .compactMap { $0?.saved }
            .asDriver(onErrorDriveWith: .never())
        
        let action = didTapBookmark
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(interaction) {  ($0, $1) }
            .flatMapLatest { [weak self] saved, interaction -> Driver<Bool> in
                guard let self = self, let id = interaction?.id else {
                    return .never()
                }
                
                func source() -> Single<Void> {
                    saved ? self.drugsManager.unsave(interactionsIds: [id]) : self.drugsManager.save(interactionId: id)
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
}
