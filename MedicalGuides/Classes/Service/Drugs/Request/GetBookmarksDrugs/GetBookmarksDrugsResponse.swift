//
//  GetBookmarksDrugsResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

enum GetBookmarksDrugsResponse {
    static func map(from response: Any) -> [Drug] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let drugsArray = data["drugs"] as? [[String: Any]]
        else {
            return []
        }
        
        return drugsArray.compactMap { json -> Drug? in
            guard
                let id = json["id"] as? Int,
                let name = json["name"] as? String,
                let saved = json["saved"] as? Bool
            else {
                return nil
            }
            
            return Drug(
                id: id,
                name: name,
                saved: saved
            )
        }
    }
}
