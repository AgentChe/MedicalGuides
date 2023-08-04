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
        case paygate
    }
    
    private let collector: Driver<SymptomCheckerCollector>
    
    private let mostSymptom: SCConfirmMostSymptomElement
    
    private lazy var sessionManager = SessionManager()
    
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
        let didAddMedication: Signal<SymptomMed>
        let didRemoveMedication: Signal<SymptomMed>
        let didAddCondition: Signal<MedicalState>
        let didRemoveCondition: Signal<MedicalState>
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
        let selectedMedications = makeSelectedMedications(action: medicationActions)
        let conditionActions = makeConditionActions(
            didAddCondition: input.didAddCondition,
            didRemoveCondition: input.didRemoveCondition
        )
        let selectedConditions = makeSelectedMedicalStates(action: conditionActions)
        let continueEnable = makeContinueEnable(didSelectMostSymptom: input.didSelectMostSymptom)
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
    enum SymptomMedAction {
        case add(SymptomMed)
        case remove(SymptomMed)
    }
    
    enum MedicalStateAction {
        case add(MedicalState)
        case remove(MedicalState)
    }
    
    func makeElements(
        selectedMedications: Driver<[SymptomMed]>,
        selectedConditions: Driver<[MedicalState]>,
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
        didSelectMostSymptom: Signal<Symptom>
    ) -> Driver<Bool> {
        didSelectMostSymptom
            .asDriver(onErrorDriveWith: .never())
            .map { symptom in true }
            .startWith(false)
    }
    
    func makeSelectedMedications(action: Driver<SymptomMedAction>) -> Driver<[SymptomMed]> {
        action
            .scan([]) { array, action -> [SymptomMed] in
                var result = array
                
                switch action {
                case .add(let med):
                    result.append(med)
                case .remove(let med):
                    result.removeAll(where: { $0.id == med.id })
                }
                
                return result
            }
            .startWith([])
    }
    
    func makeSelectedMedicalStates(action: Driver<MedicalStateAction>) -> Driver<[MedicalState]> {
        action
            .scan([]) { array, action -> [MedicalState] in
                var result = array
                
                switch action {
                case .add(let state):
                    result.append(state)
                case .remove(let state):
                    result.removeAll(where: { $0.id == state.id })
                }
                
                return result
            }
            .startWith([])
    }
    
    func makeMedicationActions(
        didAddMedication: Signal<SymptomMed>,
        didRemoveMedication: Signal<SymptomMed>
    ) -> Driver<SymptomMedAction> {
        Signal
            .merge(
                didAddMedication.map { SymptomMedAction.add($0) },
                didRemoveMedication.map { SymptomMedAction.remove($0) }
            )
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeConditionActions(
        didAddCondition: Signal<MedicalState>,
        didRemoveCondition: Signal<MedicalState>
    ) -> Driver<MedicalStateAction> {
        Signal
            .merge(
                didAddCondition.map { MedicalStateAction.add($0) },
                didRemoveCondition.map { MedicalStateAction.remove($0) }
            )
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeRoute(
        didTapChoose: Signal<SCConfirmChooseElement>,
        didTapContinue: Signal<Void>,
        didSelectMostSymptom: Signal<Symptom>,
        didSelectPregnant: Signal<Bool>,
        selectedMedications: Driver<[SymptomMed]>,
        selectedConditions: Driver<[MedicalState]>
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
        selectedMedications: Driver<[SymptomMed]>,
        selectedConditions: Driver<[MedicalState]>
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
        selectedMedications: Driver<[SymptomMed]>,
        selectedConditions: Driver<[MedicalState]>
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
                $0.medicalStatesIds = $1.3.map { $0.id }
                return $0
            }
            .map { [weak self] collector -> Route in
                if self?.sessionManager.hasActiveSubscriptions() == true {
                    return Route.continue(collector)
                } else {
                    return Route.paygate
                }
            }
            .asDriver(onErrorDriveWith: .never())
    }
}
