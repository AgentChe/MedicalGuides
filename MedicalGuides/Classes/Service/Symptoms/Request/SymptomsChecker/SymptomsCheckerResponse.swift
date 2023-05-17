//
//  SymptomsCheckerResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 16.05.2023.
//

enum SymptomsCheckerResponse {
    static func map(from response: Any) -> [SymptomsInteractionCondition] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let conditionsArray = data["conditions"] as? [[String: Any]]
        else {
            return []
        }
        
        return conditionsArray.compactMap { json -> SymptomsInteractionCondition? in
            guard
                let id = json["id"] as? Int,
                let name = json["name"] as? String,
                let saved = json["saved"] as? Bool,
                let fairMatch = json["fair_match"] as? Int
            else {
                return nil
            }
            
            return SymptomsInteractionCondition(
                id: id,
                name: name,
                saved: saved,
                fairMatch: fairMatch
            )
        }
    }
}
