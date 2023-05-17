//
//  DrugsInteractionCheckerResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

enum DrugsInteractionCheckerResponse {
    static func map(from response: Any) -> DrugsInteraction? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let id = data["id"] as? Int,
            let drugsIds = data["drug_ids"] as? [Int],
            let resultJSON = data["result"] as? [String: Any],
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
