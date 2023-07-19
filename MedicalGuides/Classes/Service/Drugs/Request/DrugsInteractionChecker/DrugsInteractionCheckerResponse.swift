//
//  DrugsInteractionCheckerResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

enum DrugsInteractionCheckerResponse {
    static func map(from response: Any) -> DrugsInteractionResult? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let hasInteraction = data["has_interaction"] as? Bool
        else {
            return nil
        }
        
        if !hasInteraction {
            return DrugsInteractionResult.none
        }
        
        guard
            let interactionJSON = data["interaction"] as? [String: Any],
            let id = interactionJSON["id"] as? Int,
            let medIds = interactionJSON["drug_ids"] as? [Int],
            let resultJSON = interactionJSON["result"] as? [String: Any],
            let title = resultJSON["title"] as? String,
            let subtitle = resultJSON["subtitle"] as? String,
            let text = resultJSON["text"] as? String,
            let sideEffectCode = resultJSON["side_effect"] as? Int,
            let sideEffect = DrugsSideEffect(code: sideEffectCode),
            let saved = resultJSON["saved"] as? Bool
        else {
            return nil
        }
        
        let interaction = DrugsInteraction(
            id: id,
            medIds: medIds,
            title: title,
            subtitle: subtitle,
            text: text,
            sideEffect: sideEffect,
            saved: saved
        )
        return DrugsInteractionResult.interaction(interaction)
    }
}
