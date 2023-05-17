//
//  GetDrugDetailsResponse.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

enum GetDrugDetailsResponse {
    static func map(from response: Any) -> DrugDetails? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let id = data["id"] as? Int,
            let name = data["name"] as? String,
            let saved = data["saved"] as? Bool,
            let sectionsArray = data["sections"] as? [[String: Any]]
        else {
            return nil
        }
        
        let sections = sectionsArray.compactMap { json -> DrugSection? in
            guard
                let name = json["name"] as? String,
                let blocksArray = json["blocks"] as? [[String: Any]]
            else {
                return nil
            }
            
            let blocks = blocksArray.compactMap { json -> DrugBlock? in
                guard let text = json["text"] as? String else {
                    return nil
                }
                
                return DrugBlock(
                    title: json["title"] as? String,
                    text: text
                )
            }
            
            return DrugSection(
                name: name,
                blocks: blocks
            )
        }
        
        return DrugDetails(
            id: id,
            name: name,
            saved: saved,
            sections: sections
        )
    }
}
