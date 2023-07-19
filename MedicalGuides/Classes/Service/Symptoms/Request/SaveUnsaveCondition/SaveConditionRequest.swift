//
//  SaveConditionRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

import Alamofire

struct SaveConditionRequest: APIRequestBody {
    let userToken: String
    let id: Int

    var url: String {
        GlobalDefinitions.domain + "/api/symptom_checker/conditions/save"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "condition_id": id
        ]
    }
}
