//
//  GetBookmarksInteractionsResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

enum GetBookmarksInteractionsResponse {
    static func map(from response: Any) -> [DrugsInteraction] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [[String: Any]]
        else {
            return []
        }
        
        return data.compactMap { json -> DrugsInteraction? in
            guard
                let id = json["id"] as? Int,
                let drugsIds = json["drug_ids"] as? [Int],
                let resultJSON = json["result"] as? [String: Any],
                let title = resultJSON["title"] as? String,
                let subtitle = resultJSON["subtitle"] as? String,
                let text = resultJSON["text"] as? String,
                let sideEffectCode = resultJSON["side_effect"] as? Int,
                let sideEffect = DrugsSideEffect(code: sideEffectCode),
                let saved = resultJSON["saved"] as? Bool
            else {
                return nil
            }
            
            return DrugsInteraction(
                id: id,
                drugsIds: drugsIds,
                title: title,
                subtitle: subtitle,
                text: text,
                sideEffect: sideEffect,
                saved: saved
            )
        }
    }
}
