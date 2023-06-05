//
//  DrugsSideEffect.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

enum DrugsSideEffect: Codable, Hashable {
    case minor
    case monitorClosely
    case serious
    case dontUseTogether
    
    init?(code: Int) {
        switch code {
        case 1:
            self = .minor
        case 2:
            self = .monitorClosely
        case 3:
            self = .serious
        case 4:
            self = .dontUseTogether
        default:
            return nil
        }
    }
}
