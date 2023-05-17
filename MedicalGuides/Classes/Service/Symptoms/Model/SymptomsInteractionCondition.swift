//
//  SymptomsInteractionCondition.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

struct SymptomsInteractionCondition: Codable, Hashable {
    let id: Int
    let name: String
    let saved: Bool
    let fairMatch: Int
}
