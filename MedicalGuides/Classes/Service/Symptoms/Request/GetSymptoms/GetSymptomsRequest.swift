//
//  GetSymptomsRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 16.05.2023.
//

import Alamofire

struct GetSymptomsRequest: APIRequestBody {
    let userToken: String
    
    var url: String {
        GlobalDefinitions.domain + "/api/symptom_checker/symptoms"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken
        ]
    }
}
