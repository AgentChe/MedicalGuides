//
//  SelectUnitTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

final class SelectUnitTableElement {
    enum Unit {
        case drug(Drug)
        case symptom(Symptom)
        case interactionCheckerMed(InteractionCheckerMed)
    }
    
    let name: String
    let isSelected: Bool
    let unit: Unit
    
    init(drug: Drug, isSelected: Bool) {
        self.name = drug.name
        self.isSelected = isSelected
        self.unit = .drug(drug)
    }
    
    init(symptom: Symptom, isSelected: Bool) {
        self.name = symptom.name
        self.isSelected = isSelected
        self.unit = .symptom(symptom)
    }
    
    init(interactionCheckerMed: InteractionCheckerMed, isSelected: Bool) {
        self.name = interactionCheckerMed.name
        self.isSelected = isSelected
        self.unit = .interactionCheckerMed(interactionCheckerMed)
    }
}
