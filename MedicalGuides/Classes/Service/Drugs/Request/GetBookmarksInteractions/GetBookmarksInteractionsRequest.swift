//
//  GetBookmarksInteractionsRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

import Alamofire

struct GetBookmarksInteractionsRequest: APIRequestBody {
    let userToken: String
    
    var url: String {
        GlobalDefinitions.domain + "/api/interaction_checker/bookmarks"
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
