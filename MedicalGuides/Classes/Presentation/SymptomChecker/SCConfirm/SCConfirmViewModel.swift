//
//  SCConfirmViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import RxSwift
import RxCocoa

final class SCConfirmViewModel {
    enum Route {
        case selectMedications(selectedIds: [Int])
        case selectConditions(selectedIds: [Int])
        case `continue`(SymptomCheckerCollector)
    }
    
    private let collector: Driver<SymptomCheckerCollector>
    
    private let mostSymptom: SCConfirmMostSymptomElement
    
    init(collector: SymptomCheckerCollector) {
        self.collector = BehaviorRelay(value: collector).asDriver()
        self.mostSymptom = SCConfirmMostSymptomElement(
            symptoms: collector.symptoms ?? [],
            mostSymptomId: nil
        )
    }
}

// MARK: Public
extension SCConfirmViewModel {
    struct Input {
        let didSelectMostSymptom: Signal<Symptom>
        let didSelectPregnant: Signal<Bool>
        let didTapChoose: Signal<SCConfirmChooseElement>
        let didAddMedication: Signal<Drug>
        let didRemoveMedication: Signal<Drug>
        let didAddCondition: Signal<Drug>
        let didRemoveCondition: Signal<Drug>
        let didTapContinue: Signal<Void>
    }
    
    struct Output {
        let elements: Driver<[SCConfirmTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let medicationActions = makeMedicationActions(
            didAddMedication: input.didAddMedication,
            didRemoveMedication: input.didRemoveMedication
        )
        let selectedMedications = makeSelectedDrugs(action: medicationActions)
        let conditionActions = makeConditionActions(
            didAddCondition: input.didAddCondition,
            didRemoveCondition: input.didRemoveCondition
        )
        let selectedConditions = makeSelectedDrugs(action: conditionActions)
        let continueEnable = makeContinueEnable(
            didSelectMostSymptom: input.didSelectMostSymptom,
            selectedMedications: selectedMedications,
            selectedConditions: selectedConditions
        )
        let didSelectPregnant = input.didSelectPregnant
            .startWith(false)
        
        return Output(
            elements: makeElements(
                selectedMedications: selectedMedications,
                selectedConditions: selectedConditions,
                continueEnable: continueEnable
            ),
            route: makeRoute(
                didTapChoose: input.didTapChoose,
                didTapContinue: input.didTapContinue,
                didSelectMostSymptom: input.didSelectMostSymptom,
                didSelectPregnant: didSelectPregnant,
                selectedMedications: selectedMedications,
                selectedConditions: selectedConditions
            )
        )
    }
}

// MARK: Private
private extension SCConfirmViewModel {
    enum Action {
        case add(Drug)
        case remove(Drug)
    }
    
    func makeElements(
        selectedMedications: Driver<[Drug]>,
        selectedConditions: Driver<[Drug]>,
        continueEnable: Driver<Bool>
    ) -> Driver<[SCConfirmTableElement]> {
        Driver
            .combineLatest(
                collector,
                selectedMedications,
                selectedConditions,
                continueEnable
            )
            .map { [weak self] collector, medications, conditions, continueEnable  -> [SCConfirmTableElement] in
                guard let self = self else {
                    return []
                }
                
                var result = [SCConfirmTableElement]()
                
                result.append(.mostSymptom(self.mostSymptom))
                
                result.append(.pregnant)
                
                result.append(.choose(.currentMedications))
                if !medications.isEmpty {
                    result.append(.medications(medications))
                }
                result.append(.description("SymptomChecker.Confirm.MedicationsDescription".localized))
                
                result.append(.choose(.conditions))
                if !conditions.isEmpty {
                    result.append(.conditions(conditions))
                }
                result.append(.description("SymptomChecker.Confirm.Conditions.Description".localized))
                
                result.append(.continue(continueEnable))
                
                return result
            }
    }
    
    func makeContinueEnable(
        didSelectMostSymptom: Signal<Symptom>,
        selectedMedications: Driver<[Drug]>,
        selectedConditions: Driver<[Drug]>
    ) -> Driver<Bool> {
        Driver
            .combineLatest(
                didSelectMostSymptom.asDriver(onErrorDriveWith: .never()),
                selectedMedications,
                selectedConditions
            )
            .map { mostSymptom, medications, conditions -> Bool in
                !medications.isEmpty && !conditions.isEmpty
            }
            .startWith(false)
    }
    
    func makeSelectedDrugs(action: Driver<Action>) -> Driver<[Drug]> {
        action
            .scan([]) { array, action -> [Drug] in
                var result = array
                
                switch action {
                case .add(let drug):
                    result.append(drug)
                case .remove(let drug):
                    result.removeAll(where: { $0.id == drug.id })
                }
                
                return result
            }
            .startWith([])
    }
    
    func makeMedicationActions(
        didAddMedication: Signal<Drug>,
        didRemoveMedication: Signal<Drug>
    ) -> Driver<Action> {
        Signal
            .merge(
                didAddMedication.map { Action.add($0) },
                didRemoveMedication.map { Action.remove($0) }
            )
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeConditionActions(
        didAddCondition: Signal<Drug>,
        didRemoveCondition: Signal<Drug>
    ) -> Driver<Action> {
        Signal
            .merge(
                didAddCondition.map { Action.add($0) },
                didRemoveCondition.map { Action.remove($0) }
            )
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeRoute(
        didTapChoose: Signal<SCConfirmChooseElement>,
        didTapContinue: Signal<Void>,
        didSelectMostSymptom: Signal<Symptom>,
        didSelectPregnant: Signal<Bool>,
        selectedMedications: Driver<[Drug]>,
        selectedConditions: Driver<[Drug]>
    ) -> Driver<Route> {
        Driver
            .merge(
                makeSelectRoute(
                    didTapChoose: didTapChoose,
                    selectedMedications: selectedMedications,
                    selectedConditions: selectedConditions
                ),
                makeContinueRoute(
                    didTapContinue: didTapContinue,
                    didSelectMostSymptom: didSelectMostSymptom,
                    didSelectPregnant: didSelectPregnant,
                    selectedMedications: selectedMedications,
                    selectedConditions: selectedConditions
                )
            )
    }
    
    func makeSelectRoute(
        didTapChoose: Signal<SCConfirmChooseElement>,
        selectedMedications: Driver<[Drug]>,
        selectedConditions: Driver<[Drug]>
    ) -> Driver<Route> {
        let selectMedications = didTapChoose
            .filter { $0 == .currentMedications }
            .withLatestFrom(selectedMedications)
            .map { Route.selectMedications(selectedIds: $0.map { $0.id }) }
            .asDriver(onErrorDriveWith: .never())
        let selectConditions = didTapChoose
            .filter { $0 == .conditions }
            .withLatestFrom(selectedConditions)
            .map { Route.selectConditions(selectedIds: $0.map { $0.id }) }
            .asDriver(onErrorDriveWith: .never())
        return Driver
            .merge(selectMedications, selectConditions)
    }
    
    func makeContinueRoute(
        didTapContinue: Signal<Void>,
        didSelectMostSymptom: Signal<Symptom>,
        didSelectPregnant: Signal<Bool>,
        selectedMedications: Driver<[Drug]>,
        selectedConditions: Driver<[Drug]>
    ) -> Driver<Route> {
        let args = Driver
            .combineLatest(
                didSelectMostSymptom.asDriver(onErrorDriveWith: .never()),
                didSelectPregnant.asDriver(onErrorDriveWith: .never()),
                selectedMedications,
                selectedConditions
            ) { ($0, $1, $2, $3) }
        
        
        return didTapContinue
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(collector)
            .withLatestFrom(args) {
                $0.mainSymptomId = $1.0.id
                $0.pregnant = $1.1
                $0.currentMedicationsIds = $1.2.map { $0.id }
                $0.conditionsIds = $1.3.map { $0.id }
                return $0
            }
            .map { Route.continue($0) }
            .asDriver(onErrorDriveWith: .never())
    }
}
