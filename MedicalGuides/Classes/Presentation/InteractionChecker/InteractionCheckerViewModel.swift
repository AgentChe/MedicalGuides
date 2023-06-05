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
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var drugsManager = DrugsManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension InteractionCheckerViewModel {
    struct Input {
        let didTapElement: Signal<InteractionCheckerDrugElement>
        let didTapDelete: Signal<InteractionCheckerDrugElement>
        let didTapAddMore: Signal<Void>
        let didTapCheck: Signal<Void>
        let didSelectDrug: Signal<(Drug, String)>
        let didTapBookmark: Signal<Bool>
    }
    
    struct Output {
        let elements: Driver<[InteractionCheckerTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let action = makeAction(
            didTapAddMore: input.didTapAddMore,
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
                selectedDrugs: selectedDrugs
            )
        )
    }
}

// MARK: Private
private extension InteractionCheckerViewModel {
    enum Action {
        case initial
        case addMore
        case deleteDrug(String)
        case select((Drug, String))
    }
    
    func makeElements(
        drugsElements: Driver<[InteractionCheckerDrugElement]>,
        selectedDrugs: Driver<[Drug]>,
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
                
                if (drugsElements.count - selectedDrugs.count) <= 1 {
                    result.append(.addMore)
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
                case .addMore:
                    let new = InteractionCheckerDrugElement(
                        id: UUID().uuidString,
                        number: elements.count + 1,
                        deleteEnabled: true,
                        mode: .choose
                    )
                    elements.append(new)
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
        didTapAddMore: Signal<Void>,
        didTapDelete: Signal<InteractionCheckerDrugElement>,
        didSelectDrug: Signal<(Drug, String)>
    ) -> Driver<Action> {
        let add = didTapAddMore
            .map { Action.addMore}
            .asDriver(onErrorDriveWith: .never())
        let delete = didTapDelete
            .map { Action.deleteDrug($0.id) }
            .asDriver(onErrorDriveWith: .never())
        let select = didSelectDrug
            .map { Action.select($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(add, delete, select)
    }
    
    func makeRoute(
        didTapElement: Signal<InteractionCheckerDrugElement>,
        selectedDrugs: Driver<[Drug]>
    ) -> Driver<Route> {
        makeSelectDrugRoute(
            didTapElement: didTapElement,
            selectedDrugs: selectedDrugs
        )
    }
    
    func makeSelectDrugRoute(
        didTapElement: Signal<InteractionCheckerDrugElement>,
        selectedDrugs: Driver<[Drug]>
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
    
    func makeSelectedDrugs(drugsElements: Driver<[InteractionCheckerDrugElement]>) -> Driver<[Drug]> {
        drugsElements.map { drugsElements -> [Drug] in
            drugsElements.compactMap { element -> Drug? in
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
        selectedDrugs: Driver<[Drug]>
    ) -> Driver<DrugsInteraction?> {
        didTapCheck
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(selectedDrugs)
            .flatMapLatest { [weak self] drugs -> Driver<DrugsInteraction?> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<DrugsInteraction?> {
                    self.drugsManager
                        .interactionCheck(drugsIds: drugs.map { $0.id })
                        .flatMap { result -> Single<DrugsInteraction?> in
                            guard let result = result else {
                                return .error(ContentError(.notContent))
                            }
                            
                            return .just(result)
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
