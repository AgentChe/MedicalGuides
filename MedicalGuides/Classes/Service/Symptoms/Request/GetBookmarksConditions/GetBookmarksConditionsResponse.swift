//
//  GetBookmarksConditionsResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

import Foundation

enum GetBookmarksConditionsResponse {
    static func map(from response: Any) -> [SymptomsInteractionConditionDetails] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let conditionsArray = data["conditions"] as? [[String: Any]]
        else {
            return []
        }
        
        return conditionsArray.compactMap { json -> SymptomsInteractionConditionDetails? in
            guard
                let id = json["id"] as? Int,
                let saved = json["saved"] as? Bool,
                let name = json["name"] as? String,
                let detailsJSON = json["details"] as? [String: Any],
                let detailsSectionsArray = detailsJSON["sections"] as? [[String: Any]],
                let treatmentOptionsJSON = json["treatment_options"] as? [String: Any],
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
}

// MARK: Private
private extension GetBookmarksConditionsResponse {
    static func blocks(from array: [[String: Any]]) -> [SymptomsCheckerSection] {
        array.compactMap { json -> SymptomsCheckerSection? in
            guard
                let name = json["name"] as? String,
                let blocksArray = json["blocks"] as? [[String: Any]]
            else {
                return nil
            }
            
            let blocks = blocksArray.compactMap { blockJSON -> SymptomsCheckerBlock? in
                guard
                    let type = blockJSON["type"] as? Int,
                    let value = blockJSON["content"] as? String
                else {
                    return nil
                }
                
                switch type {
                case 1:
                    return .text(value)
                case 2:
                    guard let url = URL(string: value) else {
                        return nil
                    }
                    
                    return .image(url)
                default:
                    return nil
                }
            }
            
            return SymptomsCheckerSection(
                name: name,
                blocks: blocks
            )
        }
    }
}
