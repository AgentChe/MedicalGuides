//
//  UnsaveDrugRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

import Alamofire

struct UnsaveDrugRequest: APIRequestBody {
    let userToken: String
    let ids: [Int]

    var url: String {
        GlobalDefinitions.domain + "/api/drugs/unsave"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "drug_ids": ids
        ]
    }
}
