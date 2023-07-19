//
//  GetSymptomsResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 16.05.2023.
//

enum GetSymptomsResponse {
    static func map(from response: Any) -> [Symptom] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let symptomsArray = data["symptoms"] as? [[String: Any]]
        else {
            return []
        }
        
        return symptomsArray.compactMap { json -> Symptom? in
            guard
                let id = json["id"] as? Int,
                let name = json["name"] as? String
            else {
                return nil
            }
            
            return Symptom(
                id: id,
                name: name
            )
        }
    }
}
