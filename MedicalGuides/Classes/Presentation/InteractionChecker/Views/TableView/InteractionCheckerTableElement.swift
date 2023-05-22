//
//  InteractionCheckerTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

enum InteractionCheckerTableElement {
    case drug(InteractionCheckerDrugElement)
    case addMore
    case check
}

struct InteractionCheckerDrugElement {
    enum Mode {
        case choose
        case drug(Drug)
    }
    
    let id: String
    let number: Int
    let deleteEnabled: Bool
    let mode: Mode
}
