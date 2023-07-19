//
//  DrugsInteraction.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

struct DrugsInteraction: Codable, Hashable {
    let id: Int
    let medIds: [Int]
    let title: String
    let subtitle: String
    let text: String
    let sideEffect: DrugsSideEffect
    let saved: Bool
}

enum DrugsInteractionResult {
    case none
    case interaction(DrugsInteraction)
}
