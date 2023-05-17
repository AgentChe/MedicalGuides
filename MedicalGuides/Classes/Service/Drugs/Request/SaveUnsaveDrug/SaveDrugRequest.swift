//
//  SaveDrugRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 15.05.2023.
//

import Alamofire

struct SaveDrugRequest: APIRequestBody {
    let userToken: String
    let id: Int

    var url: String {
        GlobalDefinitions.domain + "/api/drugs/save"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "drug_id": id
        ]
    }
}
