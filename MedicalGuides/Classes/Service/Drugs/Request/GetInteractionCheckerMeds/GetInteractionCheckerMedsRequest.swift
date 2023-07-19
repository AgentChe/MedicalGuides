//
//  GetInteractionCheckerMedsRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.07.2023.
//

import Alamofire

struct GetInteractionCheckerMedsRequest: APIRequestBody {
    let userToken: String
    let search: String?

    var url: String {
        GlobalDefinitions.domain + "/api/interaction_checker/meds"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        var params = [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken
        ]
        
        if let search = search {
            params["search"] = search
        }
        
        return params
    }
}
