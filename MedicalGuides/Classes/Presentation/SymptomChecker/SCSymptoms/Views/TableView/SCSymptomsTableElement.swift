//
//  SCSymptomsTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 25.05.2023.
//

enum SCSymptomsTableElement {
    case select
    case symptoms([Symptom])
    case `continue`(Bool)
}
