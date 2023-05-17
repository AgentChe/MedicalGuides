//
//  GetDrugsRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

import Alamofire

struct GetDrugsRequest: APIRequestBody {
    let userToken: String
    let search: String?

    var url: String {
        GlobalDefinitions.domain + "/api/drugs"
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
