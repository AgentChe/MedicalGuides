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
        currentMedicationsIds: [Int]?,
        medicalStatesIds: [Int]?
    ) -> Single<[SymptomsInteractionCondition]>
    func obtainConditionDetails(id: Int) -> Single<SymptomsInteractionConditionDetails?>
    func save(conditionId: Int) -> Single<Void>
    func unsave(conditionsIds: [Int]) -> Single<Void>
    func obtainBookmarksConditions() -> Single<[SymptomsInteractionConditionDetails]>
    func obtainMedicalStates(forceUpdate: Bool) -> Single<[MedicalState]>
    func obtainSymptomMeds(forceUpdate: Bool) -> Single<[SymptomMed]>
}

final class SymptomsManager {
    enum Constants {
        static let symptoms = "symptoms_manager_symptoms_key"
        static let medicalStates = "symptoms_manager_medical_states_key"
        static let symptomMeds = "symptoms_manager_symptom_meds_key"
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
        currentMedicationsIds: [Int]?,
        medicalStatesIds: [Int]?
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
            medicalStatesIds: medicalStatesIds
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

    func save(conditionId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = SaveConditionRequest(userToken: userToken, id: conditionId)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                SymptomsMediator.shared.saveCondition(id: conditionId)
            })
    }

    func unsave(conditionsIds: [Int]) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = UnsaveConditionRequest(userToken: userToken, ids: conditionsIds)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: { 
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
    
    func obtainMedicalStates(forceUpdate: Bool) -> Single<[MedicalState]> {
        forceUpdate ? loadMedicalStates() : cachedMedicalStates()
    }
    
    func obtainSymptomMeds(forceUpdate: Bool) -> Single<[SymptomMed]> {
        forceUpdate ? loadSymptomMeds() : cachedSymptomMeds()
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
    
    func loadMedicalStates() -> Single<[MedicalState]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetMedicalStatesRequest(userToken: userToken)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetMedicalStatesResponse.map(from: $0) }
            .do(onSuccess: { medicalStates in
                guard let data = try? JSONEncoder().encode(medicalStates) else {
                    return
                }

                UserDefaults.standard.set(data, forKey: Constants.medicalStates)
            })
    }

    func cachedMedicalStates() -> Single<[MedicalState]> {
        Single<[MedicalState]>.create { event in
            guard
                let data = UserDefaults.standard.data(forKey: Constants.medicalStates),
                let medicalStates = try? JSONDecoder().decode([MedicalState].self, from: data)
            else {
                event(.success([]))
                return Disposables.create()
            }

            event(.success(medicalStates))

            return Disposables.create()
        }
    }
    
    func loadSymptomMeds() -> Single<[SymptomMed]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetSymptomMedsRequest(userToken: userToken)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetSymptomMedsResponse.map(from: $0) }
            .do(onSuccess: { meds in
                guard let data = try? JSONEncoder().encode(meds) else {
                    return
                }

                UserDefaults.standard.set(data, forKey: Constants.symptomMeds)
            })
    }
    
    func cachedSymptomMeds() -> Single<[SymptomMed]> {
        Single<[SymptomMed]>.create { event in
            guard
                let data = UserDefaults.standard.data(forKey: Constants.symptomMeds),
                let meds = try? JSONDecoder().decode([SymptomMed].self, from: data)
            else {
                event(.success([]))
                return Disposables.create()
            }

            event(.success(meds))

            return Disposables.create()
        }
    }
}
