//
//  GetBookmarksDrugsRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

import Alamofire

struct GetBookmarksDrugsRequest: APIRequestBody {
    let userToken: String

    var url: String {
        GlobalDefinitions.domain + "/api/drugs/bookmarks"
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
