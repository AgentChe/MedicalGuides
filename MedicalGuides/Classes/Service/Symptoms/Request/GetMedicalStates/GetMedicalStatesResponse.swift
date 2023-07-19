//
//  GetMedicalStatesResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.07.2023.
//

enum GetMedicalStatesResponse {
    static func map(from response: Any) -> [MedicalState] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let medicalStatesArray = data["medical_states"] as? [[String: Any]]
        else {
            return []
        }
        
        return medicalStatesArray.compactMap { json -> MedicalState? in
            guard
                let id = json["id"] as? Int,
                let name = json["name"] as? String
            else {
                return nil
            }
            
            return MedicalState(
                id: id,
                name: name
            )
        }
    }
}
