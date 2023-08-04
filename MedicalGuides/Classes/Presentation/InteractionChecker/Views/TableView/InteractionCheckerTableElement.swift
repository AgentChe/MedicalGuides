//
//  InteractionCheckerTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

enum InteractionCheckerTableElement {
    case drug(InteractionCheckerDrugElement)
    case check
    case preloader
    case result(InteractionCheckerResultElement)
}

struct InteractionCheckerDrugElement {
    enum Mode {
        case choose
        case drug(InteractionCheckerMed)
    }
    
    let id: String
    let number: Int
    let mode: Mode
}

struct InteractionCheckerResultElement {
    let result: DrugsInteraction
    let marked: Bool
}
