//
//  DrugsInteractionCheckerRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

import Alamofire

struct DrugsInteractionCheckerRequest: APIRequestBody {
    let userToken: String
    let interactionMedIds: [Int]

    var url: String {
        GlobalDefinitions.domain + "/api/interaction_checker/analyze"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "interaction_med_ids": interactionMedIds
        ]
    }
}
