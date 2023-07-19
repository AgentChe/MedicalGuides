//
//  SymptomsInteractionConditionDetails.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

struct SymptomsInteractionConditionDetails: Codable, Hashable {
    let id: Int
    let name: String
    let saved: Bool
    let details: [SymptomsCheckerSection]
    let treatmentOptions: [SymptomsCheckerSection]
}
