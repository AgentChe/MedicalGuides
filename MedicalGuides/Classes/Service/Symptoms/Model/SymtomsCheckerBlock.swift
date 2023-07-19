//
//  SymptomsCheckerBlock.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.07.2023.
//

import Foundation

enum SymptomsCheckerBlock: Codable, Hashable {
    case image(URL)
    case text(String)
}
