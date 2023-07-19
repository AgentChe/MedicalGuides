//
//  GetSymptomMedsRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.07.2023.
//

import Alamofire

struct GetSymptomMedsRequest: APIRequestBody {
    let userToken: String
    
    var url: String {
        GlobalDefinitions.domain + "/api/symptom_checker/meds"
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
