//
//  GetInteractionCheckerMedsResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.07.2023.
//

enum GetInteractionCheckerMedsResponse {
    static func map(from response: Any) -> [InteractionCheckerMed] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [[String: Any]]
        else {
            return []
        }
        
        return data.compactMap { json -> InteractionCheckerMed? in
            guard
                let id = json["id"] as? Int,
                let name = json["name"] as? String
            else {
                return nil
            }
            
            return InteractionCheckerMed(
                id: id,
                name: name
            )
        }
    }
}
