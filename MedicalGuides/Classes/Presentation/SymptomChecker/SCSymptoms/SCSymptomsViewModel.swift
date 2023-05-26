//
//  SCSymptomsViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import RxSwift
import RxCocoa

final class SCSymptomsViewModel {
    enum Route {
        case selectSymptom([Int])
    }
}

// MARK: Public
extension SCSymptomsViewModel {
    struct Input {
        let didTapSelect: Signal<Void>
        let didAddSymptom: Signal<Symptom>
        let didRemoveSymptom: Signal<Symptom>
    }
    
    struct Output {
        let elements: Driver<[SCSymptomsTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let action = makeActions(
            didAddSymptom: input.didAddSymptom,
            didRemoveSymptom: input.didRemoveSymptom
        )
        let selectedSymptoms = makeSelectedSymptoms(action: action)
        
        return Output(
            elements: makeElements(selectedSymptoms: selectedSymptoms),
            route: makeRoute(
                didTapSelect: input.didTapSelect,
                selectedSymptoms: selectedSymptoms
            )
        )
    }
}

// MARK: Private
private extension SCSymptomsViewModel {
    enum Action {
        case add(Symptom)
        case remove(Symptom)
    }
    
    func makeElements(selectedSymptoms: Driver<[Symptom]>) -> Driver<[SCSymptomsTableElement]> {
        selectedSymptoms
            .map { symptoms -> [SCSymptomsTableElement] in
                var result: [SCSymptomsTableElement] = [.select]
                
                if !symptoms.isEmpty {
                    result.append(.symptoms(symptoms))
                }
                
                result.append(.continue(!symptoms.isEmpty))
                
                return result
            }
    }
    
    func makeActions(
        didAddSymptom: Signal<Symptom>,
        didRemoveSymptom: Signal<Symptom>
    ) -> Driver<Action> {
        Signal
            .merge(
                didAddSymptom.map { Action.add($0) },
                didRemoveSymptom.map { Action.remove($0) }
            )
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeSelectedSymptoms(action: Driver<Action>) -> Driver<[Symptom]> {
        action
            .scan([]) { array, action -> [Symptom] in
                var result = array
                
                switch action {
                case .add(let symptom):
                    result.append(symptom)
                case .remove(let symptom):
                    result.removeAll(where: { $0.id == symptom.id })
                }
                
                return result
            }
            .startWith([])
    }
    
    func makeRoute(
        didTapSelect: Signal<Void>,
        selectedSymptoms: Driver<[Symptom]>
    ) -> Driver<Route> {
        Driver
            .merge(
                makeSelectRoute(
                    didTapSelect: didTapSelect,
                    selectedSymptoms: selectedSymptoms
                )
            )
    }
    
    func makeSelectRoute(
        didTapSelect: Signal<Void>,
        selectedSymptoms: Driver<[Symptom]>
    ) -> Driver<Route> {
        didTapSelect
            .withLatestFrom(selectedSymptoms)
            .map {
                Route.selectSymptom($0.map { $0.id })
            }
            .asDriver(onErrorDriveWith: .never())
    }
}
