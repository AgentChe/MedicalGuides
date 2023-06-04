//
//  SymptomsManager.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

import RxSwift

protocol SymptomsManagerProtocol {
    func obtainSymptoms(forceUpdate: Bool) -> Single<[Symptom]>
    func checkOnInteraction(
        age: Int,
        sex: Int,
        symptomsIds: [Int],
        mainSymptomId: Int,
        pregnant: Bool,
        currentMedicationsIds: [Int],
        conditionsIds: [Int]
    ) -> Single<[SymptomsInteractionCondition]>
    func obtainConditionDetails(id: Int) -> Single<SymptomsInteractionConditionDetails?>
    func save(conditionId: Int) -> Single<Bool>
    func unsave(conditionsIds: [Int]) -> Single<Bool>
    func obtainBookmarksConditions() -> Single<[SymptomsInteractionConditionDetails]>
}

final class SymptomsManager {
    enum Constants {
        static let symptoms = "symptoms_manager_symptoms_key"
    }

    private lazy var sessionManager = SessionManager()

    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
}

// MARK: SymptomsManagerProtocol
extension SymptomsManager: SymptomsManagerProtocol {
    func obtainSymptoms(forceUpdate: Bool) -> Single<[Symptom]> {
        forceUpdate ? loadSymptoms() : cachedSymptoms()
    }

    func checkOnInteraction(
        age: Int,
        sex: Int,
        symptomsIds: [Int],
        mainSymptomId: Int,
        pregnant: Bool,
        currentMedicationsIds: [Int],
        conditionsIds: [Int]
    ) -> Single<[SymptomsInteractionCondition]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = SymptomsCheckerRequest(
            userToken: userToken,
            age: age,
            sex: sex,
            symptomsIds: symptomsIds,
            mainSymptomId: mainSymptomId,
            pregnant: pregnant,
            currentMedicationsIds: currentMedicationsIds,
            conditionsIds: conditionsIds
        )

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { SymptomsCheckerResponse.map(from: $0) }
    }

    func obtainConditionDetails(id: Int) -> Single<SymptomsInteractionConditionDetails?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetConditionDetailsRequest(userToken: userToken, id: id)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetConditionDetailsResponse.map(from: $0) }
    }

    func save(conditionId: Int) -> Single<Bool> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = SaveConditionRequest(userToken: userToken, id: conditionId)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { SaveUnsaveConditionResponse.map(from: $0) }
            .do(onSuccess: { success in
                guard success else {
                    return
                }

                SymptomsMediator.shared.saveCondition(id: conditionId)
            })
    }

    func unsave(conditionsIds: [Int]) -> Single<Bool> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = UnsaveConditionRequest(userToken: userToken, ids: conditionsIds)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { SaveUnsaveConditionResponse.map(from: $0) }
            .do(onSuccess: { success in
                guard success else {
                    return
                }

                SymptomsMediator.shared.unsaveConditions(ids: conditionsIds)
            })
    }

    func obtainBookmarksConditions() -> Single<[SymptomsInteractionConditionDetails]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetBookmarksConditionsRequest(userToken: userToken)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetBookmarksConditionsResponse.map(from: $0) }
    }
}

// MARK: Private
private extension SymptomsManager {
    func loadSymptoms() -> Single<[Symptom]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetSymptomsRequest(userToken: userToken)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetSymptomsResponse.map(from: $0) }
            .do(onSuccess: { symptoms in
                guard let data = try? JSONEncoder().encode(symptoms) else {
                    return
                }

                UserDefaults.standard.set(data, forKey: Constants.symptoms)
            })
    }

    func cachedSymptoms() -> Single<[Symptom]> {
        Single<[Symptom]>.create { event in
            guard
                let data = UserDefaults.standard.data(forKey: Constants.symptoms),
                let symptoms = try? JSONDecoder().decode([Symptom].self, from: data)
            else {
                event(.success([]))
                return Disposables.create()
            }

            event(.success(symptoms))

            return Disposables.create()
        }
    }
}
