//
//  GetConditionDetailsResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

enum GetConditionDetailsResponse {
    static func map(from response: Any) -> SymptomsInteractionConditionDetails? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let id = data["id"] as? Int,
            let saved = data["saved"] as? Bool,
            let name = data["name"] as? String,
            let detailsJSON = data["details"] as? [String: Any],
            let detailsSectionsArray = detailsJSON["sections"] as? [[String: Any]],
            let treatmentOptionsJSON = data["treatment_options"] as? [String: Any],
            let treatmentOptionsSectionsArray = treatmentOptionsJSON["sections"] as? [[String: Any]]
        else {
            return nil
        }
        
        let details = blocks(from: detailsSectionsArray)
        let treatmentOptions = blocks(from: treatmentOptionsSectionsArray)
        
        return SymptomsInteractionConditionDetails(
            id: id,
            name: name,
            saved: saved,
            details: details,
            treatmentOptions: treatmentOptions
        )
    }
}

// MARK: Private
private extension GetConditionDetailsResponse {
    static func blocks(from array: [[String: Any]]) -> [DrugBlock] {
        array.compactMap { json -> DrugBlock? in
            guard let text = json["text"] as? String else {
                return nil
            }
            
            return DrugBlock(
                title: json["title"] as? String,
                text: text
            )
        }
    }
}
