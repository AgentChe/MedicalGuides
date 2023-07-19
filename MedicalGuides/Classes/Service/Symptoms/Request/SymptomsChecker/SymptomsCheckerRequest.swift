//
//  SymptomsCheckerRequest.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 16.05.2023.
//

import Alamofire

struct SymptomsCheckerRequest: APIRequestBody {
    let userToken: String
    let age: Int
    let sex: Int
    let symptomsIds: [Int]
    let mainSymptomId: Int
    let pregnant: Bool
    let currentMedicationsIds: [Int]
    let medicalStatesIds: [Int]
    
    var url: String {
        GlobalDefinitions.domain + "/api/symptom_checker/analyze"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "age": age,
            "sex": sex,
            "symptoms_ids": symptomsIds,
            "main_symptom_id": mainSymptomId,
            "pregnant": pregnant,
            "current_medications_ids": currentMedicationsIds,
            "medical_states_ids": medicalStatesIds
        ]
    }
}
