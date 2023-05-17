//
//  DrugsSideEffect.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

// TODO: актуализировать, когда станут известны все возможные побочные эффекты
enum DrugsSideEffect: Codable, Hashable {
    case minor
    
    init?(code: Int) {
        self = .minor
    }
}
