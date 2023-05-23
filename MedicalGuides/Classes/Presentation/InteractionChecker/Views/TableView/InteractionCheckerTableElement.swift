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
    case preloader
    case result(InteractionCheckerResultElement)
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

struct InteractionCheckerResultElement {
    let result: DrugsInteraction
    let marked: Bool
}
