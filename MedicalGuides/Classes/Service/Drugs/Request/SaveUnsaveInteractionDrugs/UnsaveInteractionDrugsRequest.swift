//
//  UnsaveInteractionDrugsRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

import Alamofire

struct UnsaveInteractionDrugsRequest: APIRequestBody {
    let userToken: String
    let ids: [Int]

    var url: String {
        GlobalDefinitions.domain + "/api/interaction_checker/unsave"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "drugs_interactions_ids": ids
        ]
    }
}
