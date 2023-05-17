//
//  DrugSection.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

struct DrugSection: Codable, Hashable {
    let name: String
    let blocks: [DrugBlock]
}
