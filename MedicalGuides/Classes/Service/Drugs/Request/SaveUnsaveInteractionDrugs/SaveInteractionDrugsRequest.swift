//
//  SaveInteractionDrugsRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

import Alamofire

struct SaveInteractionDrugsRequest: APIRequestBody {
    let userToken: String
    let id: Int

    var url: String {
        GlobalDefinitions.domain + "/api/interaction_checker/save"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "drugs_interaction_id": id
        ]
    }
}
