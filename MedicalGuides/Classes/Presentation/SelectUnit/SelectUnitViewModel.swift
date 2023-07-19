//
//  SelectUnitViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

import RxSwift
import RxCocoa

final class SelectUnitViewModel {
    enum Unit {
        case drugs, symptoms, interactionCheckerMed, medicalStates, symptomMeds
    }
    
    enum Route {
        case result(Result)
    }
    
    enum Result {
        case drug(Drug)
        case symptom(Symptom)
        case interactionCheckerMed(InteractionCheckerMed)
        case medicalState(MedicalState)
        case symptomMed(SymptomMed)
    }
    
    private lazy var currentElements = makeCurrentElements()
    private lazy var drugsElements = makeDrugsElements()
    private lazy var symptomsElements = makeSymptomsElements()
    private lazy var medicalStatesElements = makeMedicalStatesElements()
    private lazy var interationCheckerMedsElements = makeInteractionCheckerMedsElements()
    private lazy var symptomsMeds = makeSymptomsMedsElements()
    private let unit: Driver<Unit>
    private let selectedIds: Driver<[Int]>
    
    private lazy var drugsManager = DrugsManager()
    private lazy var symptomsManager = SymptomsManager()
    
    init(unit: Unit, selectedIds: [Int]) {
        self.unit = BehaviorRelay(value: unit).asDriver()
        self.selectedIds = BehaviorRelay(value: selectedIds).asDriver()
    }
}

// MARK: Public
extension SelectUnitViewModel {
    struct Input {
        let didSearch: Signal<String>
        let didSelect: Signal<SelectUnitTableElement>
    }
    
    struct Output {
        let elements: Driver<[SelectUnitTableElement]>
        let isEmpty: Driver<Bool>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let elements = makeElements(didSearch: input.didSearch)
        
        return Output(
            elements: elements,
            isEmpty: makeIsEmpty(
                didSearch: input.didSearch,
                elements: elements
            ),
            route: makeRoute(didSelect: input.didSelect)
        )
    }
}

// MARK: Private
private extension SelectUnitViewModel {
    func makeRoute(didSelect: Signal<SelectUnitTableElement>) -> Driver<Route> {
        didSelect
            .asDriver(onErrorDriveWith: .never())
            .flatMapLatest { element -> Driver<Route> in
                guard !element.isSelected else {
                    return .never()
                }
                
                let result: Result
                switch element.unit {
                case .drug(let drug):
                    result = .drug(drug)
                case .symptom(let symptom):
                    result = .symptom(symptom)
                case .interactionCheckerMed(let med):
                    result = .interactionCheckerMed(med)
                case .medicalState(let medicalState):
                    result = .medicalState(medicalState)
                case .symptomMed(let symptomMed):
                    result = .symptomMed(symptomMed)
                }
                
                return .just(.result(result))
            }
    }
    
    func makeElements(didSearch: Signal<String>) -> Driver<[SelectUnitTableElement]> {
        Driver
            .combineLatest(
                didSearch.asDriver(onErrorDriveWith: .never()),
                currentElements
            )
            .map { search, elements -> [SelectUnitTableElement] in
                elements.filter { element -> Bool in
                    element.name.contains(search)
                }
            }
    }
    
    func makeIsEmpty(didSearch: Signal<String>, elements: Driver<[SelectUnitTableElement]>) -> Driver<Bool> {
        Driver
            .combineLatest(
                didSearch.asDriver(onErrorJustReturn: ""),
                elements
            )
            .map { search, elements -> Bool in
                guard !search.isEmpty else {
                    return false
                }
                
                return elements.isEmpty
            }
            .startWith(false)
    }
    
    func makeCurrentElements() -> Driver<[SelectUnitTableElement]> {
        Driver
            .combineLatest(
                unit,
                drugsElements,
                symptomsElements,
                interationCheckerMedsElements,
                medicalStatesElements,
                symptomsMeds
            ) { unit, drugs, symptoms, interationCheckerMeds, medicalStates, symptomsMeds -> [SelectUnitTableElement] in
                switch unit {
                case .drugs:
                    return drugs
                case .symptoms:
                    return symptoms
                case .interactionCheckerMed:
                    return interationCheckerMeds
                case .medicalStates:
                    return medicalStates
                case .symptomMeds:
                    return symptomsMeds
                }
            }
    }
    
    func makeDrugsElements() -> Driver<[SelectUnitTableElement]> {
        Driver
            .combineLatest(
                drugsManager
                    .obtainDrugs(forceUpdate: false)
                    .asDriver(onErrorJustReturn: []),
                selectedIds
            )
            .map { drugs, selectedIds -> [SelectUnitTableElement] in
                drugs.map { drug -> SelectUnitTableElement in
                    SelectUnitTableElement(
                        drug: drug,
                        isSelected: selectedIds.contains(where: { $0 == drug.id })
                    )
                }
            }
    }
    
    func makeSymptomsElements() -> Driver<[SelectUnitTableElement]> {
        Driver
            .combineLatest(
                symptomsManager
                    .obtainSymptoms(forceUpdate: false)
                    .asDriver(onErrorJustReturn: []),
                selectedIds
            )
            .map { symptoms, selectedIds -> [SelectUnitTableElement] in
                symptoms.map { symptom -> SelectUnitTableElement in
                    SelectUnitTableElement(
                        symptom: symptom,
                        isSelected: selectedIds.contains(where: { $0 == symptom.id })
                    )
                }
            }
    }
    
    func makeMedicalStatesElements() -> Driver<[SelectUnitTableElement]> {
        Driver
            .combineLatest(
                symptomsManager
                    .obtainMedicalStates(forceUpdate: false)
                    .asDriver(onErrorJustReturn: []),
                selectedIds
            )
            .map { medicalStates, selectedIds -> [SelectUnitTableElement] in
                medicalStates.map { medicalState -> SelectUnitTableElement in
                    SelectUnitTableElement(
                        medicalState: medicalState,
                        isSelected: selectedIds.contains(where: { $0 == medicalState.id })
                    )
                }
            }
    }
    
    func makeInteractionCheckerMedsElements() -> Driver<[SelectUnitTableElement]> {
        Driver
            .combineLatest(
                drugsManager
                    .obtainInteractionCheckerMeds(forceUpdate: false)
                    .asDriver(onErrorJustReturn: []),
                selectedIds
            )
            .map { meds, selectedIds -> [SelectUnitTableElement] in
                meds.map { med -> SelectUnitTableElement in
                    SelectUnitTableElement(
                        interactionCheckerMed: med,
                        isSelected: selectedIds.contains(where: { $0 == med.id })
                    )
                }
            }
    }
    
    func makeSymptomsMedsElements() -> Driver<[SelectUnitTableElement]> {
        Driver
            .combineLatest(
                symptomsManager
                    .obtainSymptomMeds(forceUpdate: false)
                    .asDriver(onErrorJustReturn: []),
                selectedIds
            )
            .map { symptomMeds, selectedIds -> [SelectUnitTableElement] in
                symptomMeds.map { symptomMed -> SelectUnitTableElement in
                    SelectUnitTableElement(
                        symptomMed: symptomMed,
                        isSelected: selectedIds.contains(where: { $0 == symptomMed.id })
                    )
                }
            }
    }
}
