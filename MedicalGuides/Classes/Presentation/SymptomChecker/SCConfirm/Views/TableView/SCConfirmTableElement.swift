//
//  SCConfirmTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 26.05.2023.
//

enum SCConfirmTableElement {
    case mostSymptom(SCConfirmMostSymptomElement)
    case pregnant
    case choose(SCConfirmChooseElement)
    case description(String)
    case `continue`(Bool)
    case medications([SymptomMed])
    case conditions([MedicalState])
}

final class SCConfirmMostSymptomElement {
    let symptoms: [Symptom]
    var mostSymptomId: Int?
    
    init(symptoms: [Symptom], mostSymptomId: Int?) {
        self.symptoms = symptoms
        self.mostSymptomId = mostSymptomId
    }
}

enum SCConfirmChooseElement {
    case currentMedications
    case conditions
}
