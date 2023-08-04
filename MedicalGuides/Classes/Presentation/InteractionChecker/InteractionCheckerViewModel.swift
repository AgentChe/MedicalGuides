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
    private let initialInteraction: Driver<DrugsInteraction?>
    
    private lazy var drugsManager = DrugsManager()
    private lazy var sessionManager = SessionManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(drugsInteraction: DrugsInteraction?) {
        self.initialInteraction = BehaviorRelay(value: drugsInteraction).asDriver()
    }
}

// MARK: Public
extension InteractionCheckerViewModel {
    struct Input {
        let didTapElement: Signal<InteractionCheckerDrugElement>
        let didTapCheck: Signal<Void>
        let didSelectDrug: Signal<(InteractionCheckerMed, String)>
        let didTapBookmark: Signal<Bool>
    }
    
    struct Output {
        let elements: Driver<[InteractionCheckerTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let meds = makeMeds()
        let action = makeAction(
            meds: meds,
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
        case initial((DrugsInteraction, [InteractionCheckerMed])?)
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
            .scan([]) { array, action -> [InteractionCheckerDrugElement] in
                var elements = array
                
                switch action {
                case .initial(let args):
                    if let args = args {
                        let interaction = args.0
                        let meds = args.1
                        
                        let filtered = meds.filter { med in interaction.medIds.contains(where: { $0 == med.id }) }
                        
                        var firstMed: InteractionCheckerDrugElement.Mode {
                            guard let first = filtered[safe: 0] else {
                                return .choose
                            }
                            
                            return .drug(first)
                        }
                        var secondMed: InteractionCheckerDrugElement.Mode {
                            guard let second = filtered[safe: 1] else {
                                return .choose
                            }
                            
                            return .drug(second)
                        }
                        
                        elements = [
                            InteractionCheckerDrugElement(
                                id: UUID().uuidString,
                                number: 1,
                                mode: firstMed
                            ),
                            InteractionCheckerDrugElement(
                                id: UUID().uuidString,
                                number: 2,
                                mode: secondMed
                            )
                        ]
                    } else {
                        elements = [
                            InteractionCheckerDrugElement(
                                id: UUID().uuidString,
                                number: 1,
                                mode: .choose
                            ),
                            InteractionCheckerDrugElement(
                                id: UUID().uuidString,
                                number: 2,
                                mode: .choose
                            )
                        ]
                    }
                case let .select((drug, forId)):
                    guard let index = elements.firstIndex(where: { $0.id == forId }) else {
                        break
                    }
                    
                    let old = elements[index]
                    
                    let new = InteractionCheckerDrugElement(
                        id: old.id,
                        number: old.number,
                        mode: .drug(drug)
                    )
                    elements[index] = new
                }
                
                return elements
            }
    }
    
    func makeAction(
        meds: Driver<[InteractionCheckerMed]>,
        didSelectDrug: Signal<(InteractionCheckerMed, String)>
    ) -> Driver<Action> {
        let initial = Driver
            .zip(initialInteraction, meds)
            .map { interaction, meds -> Action in
                guard let interaction = interaction else {
                    return Action.initial(nil)
                }
                
                return Action.initial((interaction, meds))
            }
        let select = didSelectDrug
            .map { Action.select($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(initial, select)
    }
    
    func makeMeds() -> Driver<[InteractionCheckerMed]> {
        drugsManager
            .obtainInteractionCheckerMeds(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
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
        let check = didTapCheck
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
        
        let initial = initialInteraction
            .filter { $0 != nil }
        
        return Driver
            .merge(check, initial)
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
