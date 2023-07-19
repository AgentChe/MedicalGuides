//
//  GetSymptomMedsResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.07.2023.
//

enum GetSymptomMedsResponse {
    static func map(from response: Any) -> [SymptomMed] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let medsArray = data["meds"] as? [[String: Any]]
        else {
            return []
        }
        
        return medsArray.compactMap { json -> SymptomMed? in
            guard
                let id = json["id"] as? Int,
                let name = json["name"] as? String
            else {
                return nil
            }
            
            return SymptomMed(
                id: id,
                name: name
            )
        }
    }
}
