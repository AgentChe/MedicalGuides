//
//  SaveUnsaveConditionResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

enum SaveUnsaveConditionResponse {
    static func map(from response: Any) -> Bool {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let success = data["success"] as? Bool
        else {
            return false
        }
        
        return success
    }
}
