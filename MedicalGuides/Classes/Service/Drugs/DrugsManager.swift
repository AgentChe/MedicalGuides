//
//  DrugsManager.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

import RxSwift

protocol DrugsManagerProtocol {
    func obtainDrugs(forceUpdate: Bool) -> Single<[Drug]>
    func obtainDrugDetails(id: Int) -> Single<DrugDetails?>
    func save(drugId: Int) -> Single<Void>
    func unsave(drugsIds: [Int]) -> Single<Void>
    func obtainBookmarksDrugs() -> Single<[Drug]>
    func interactionCheck(medIds: [Int]) -> Single<DrugsInteractionResult?>
    func save(interactionId: Int) -> Single<Void>
    func unsave(interactionsIds: [Int]) -> Single<Void>
    func obtainBookmarksInteractions() -> Single<[DrugsInteraction]>
    func obtainInteractionCheckerMeds(forceUpdate: Bool) -> Single<[InteractionCheckerMed]>
}

final class DrugsManager {
    enum Constants {
        static let drugs = "drugs_manager_drugs_key"
        static let interactionCheckerMeds = "drugs_manager_interactions_checker_meds_key"
    }

    private lazy var sessionManager = SessionManager()

    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
}

extension DrugsManager: DrugsManagerProtocol {
    func obtainDrugs(forceUpdate: Bool) -> Single<[Drug]> {
        forceUpdate ? loadDrugs() : cachedDrugs()
    }

    func obtainDrugDetails(id: Int) -> Single<DrugDetails?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetDrugDetailsRequest(userToken: userToken, id: id)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetDrugDetailsResponse.map(from: $0) }
    }

    func save(drugId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = SaveDrugRequest(userToken: userToken, id: drugId)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                DrugsMediator.shared.saveDrug(id: drugId)
            })
    }

    func unsave(drugsIds: [Int]) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = UnsaveDrugRequest(userToken: userToken, ids: drugsIds)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                DrugsMediator.shared.unsaveDrugs(ids: drugsIds)
            })
    }

    func obtainBookmarksDrugs() -> Single<[Drug]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetBookmarksDrugsRequest(userToken: userToken)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetBookmarksDrugsResponse.map(from: $0) }
    }

    func interactionCheck(medIds: [Int]) -> Single<DrugsInteractionResult?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = DrugsInteractionCheckerRequest(userToken: userToken, interactionMedIds: medIds)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { DrugsInteractionCheckerResponse.map(from: $0) }
    }

    func save(interactionId: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = SaveInteractionDrugsRequest(userToken: userToken, id: interactionId)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                DrugsMediator.shared.saveInteraction(id: interactionId)
            })
    }

    func unsave(interactionsIds: [Int]) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = UnsaveInteractionDrugsRequest(userToken: userToken, ids: interactionsIds)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                DrugsMediator.shared.unsaveInteractions(ids: interactionsIds)
            })
    }

    func obtainBookmarksInteractions() -> Single<[DrugsInteraction]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetBookmarksInteractionsRequest(userToken: userToken)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetBookmarksInteractionsResponse.map(from: $0) }
    }
    
    func obtainInteractionCheckerMeds(forceUpdate: Bool) -> Single<[InteractionCheckerMed]> {
        forceUpdate ? loadInteractionCheckerMeds() : cachedInteractionCheckerMeds()
    }
}

// MARK: Private
private extension DrugsManager {
    func loadDrugs() -> Single<[Drug]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetDrugsRequest(userToken: userToken, search: nil)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetDrugsResponse.map(from: $0) }
            .do(onSuccess: { drugs in
                guard let data = try? JSONEncoder().encode(drugs) else {
                    return
                }

                UserDefaults.standard.set(data, forKey: Constants.drugs)
            })
    }

    func cachedDrugs() -> Single<[Drug]> {
        Single<[Drug]>.create { event in
            guard
                let data = UserDefaults.standard.data(forKey: Constants.drugs),
                let drugs = try? JSONDecoder().decode([Drug].self, from: data)
            else {
                event(.success([]))
                return Disposables.create()
            }

            event(.success(drugs))

            return Disposables.create()
        }
    }
    
    func loadInteractionCheckerMeds() -> Single<[InteractionCheckerMed]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }

        let request = GetInteractionCheckerMedsRequest(userToken: userToken, search: nil)

        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetInteractionCheckerMedsResponse.map(from: $0) }
            .do(onSuccess: { meds in
                guard let data = try? JSONEncoder().encode(meds) else {
                    return
                }

                UserDefaults.standard.set(data, forKey: Constants.interactionCheckerMeds)
            })
    }
    
    func cachedInteractionCheckerMeds() -> Single<[InteractionCheckerMed]> {
        Single<[InteractionCheckerMed]>.create { event in
            guard
                let data = UserDefaults.standard.data(forKey: Constants.interactionCheckerMeds),
                let meds = try? JSONDecoder().decode([InteractionCheckerMed].self, from: data)
            else {
                event(.success([]))
                return Disposables.create()
            }

            event(.success(meds))

            return Disposables.create()
        }
    }
}
