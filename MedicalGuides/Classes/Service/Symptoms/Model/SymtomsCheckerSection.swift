//
//  SymptomsCheckerSection.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.07.2023.
//

struct SymptomsCheckerSection: Codable, Hashable {
    let name: String
    let blocks: [SymptomsCheckerBlock]
}
