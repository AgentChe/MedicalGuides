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
    func save(drugId: Int) -> Single<Bool>
    func unsave(drugsIds: [Int]) -> Single<Bool>
    func obtainBookmarksDrugs() -> Single<[Drug]>
    func interactionCheck(drugsIds: [Int]) -> Single<DrugsInteraction?>
    func save(interactionId: Int) -> Single<Bool>
    func unsave(interactionsIds: [Int]) -> Single<Bool>
    func obtainBookmarksInteractions() -> Single<[DrugsInteraction]>
}

// TODO: удалить Mocks папку и вернуть реализацию
//final class DrugsManager {
//    enum Constants {
//        static let drugs = "drugs_manager_drugs_key"
//    }
//
//    private lazy var sessionManager = SessionManager()
//
//    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
//}
//
//extension DrugsManager: DrugsManagerProtocol {
//    func obtainDrugs(forceUpdate: Bool) -> Single<[Drug]> {
//        forceUpdate ? loadDrugs() : cachedDrugs()
//    }
//
//    func obtainDrugDetails(id: Int) -> Single<DrugDetails?> {
//        guard let userToken = sessionManager.getSession()?.userToken else {
//            return .error(SignError.tokenNotFound)
//        }
//
//        let request = GetDrugDetailsRequest(userToken: userToken, id: id)
//
//        return defaultRequestWrapper
//            .callServerApi(requestBody: request)
//            .map { GetDrugDetailsResponse.map(from: $0) }
//    }
//
//    func save(drugId: Int) -> Single<Bool> {
//        guard let userToken = sessionManager.getSession()?.userToken else {
//            return .error(SignError.tokenNotFound)
//        }
//
//        let request = SaveDrugRequest(userToken: userToken, id: drugId)
//
//        return defaultRequestWrapper
//            .callServerApi(requestBody: request)
//            .map { SaveUnsaveDrugResponse.map(from: $0) }
//            .do(onSuccess: { succes in
//                guard succes else {
//                    return
//                }
//
//                DrugsMediator.shared.saveDrug(id: drugId)
//            })
//    }
//
//    func unsave(drugsIds: [Int]) -> Single<Bool> {
//        guard let userToken = sessionManager.getSession()?.userToken else {
//            return .error(SignError.tokenNotFound)
//        }
//
//        let request = UnsaveDrugRequest(userToken: userToken, ids: drugsIds)
//
//        return defaultRequestWrapper
//            .callServerApi(requestBody: request)
//            .map { SaveUnsaveDrugResponse.map(from: $0) }
//            .do(onSuccess: { succes in
//                guard succes else {
//                    return
//                }
//
//                DrugsMediator.shared.unsaveDrugs(ids: drugsIds)
//            })
//    }
//
//    func obtainBookmarksDrugs() -> Single<[Drug]> {
//        guard let userToken = sessionManager.getSession()?.userToken else {
//            return .error(SignError.tokenNotFound)
//        }
//
//        let request = GetBookmarksDrugsRequest(userToken: userToken)
//
//        return defaultRequestWrapper
//            .callServerApi(requestBody: request)
//            .map { GetBookmarksDrugsResponse.map(from: $0) }
//    }
//
//    func interactionCheck(drugsIds: [Int]) -> Single<DrugsInteraction?> {
//        guard let userToken = sessionManager.getSession()?.userToken else {
//            return .error(SignError.tokenNotFound)
//        }
//
//        let request = DrugsInteractionCheckerRequest(userToken: userToken, drugsIds: drugsIds)
//
//        return defaultRequestWrapper
//            .callServerApi(requestBody: request)
//            .map { DrugsInteractionCheckerResponse.map(from: $0) }
//    }
//
//    func save(interactionId: Int) -> Single<Bool> {
//        guard let userToken = sessionManager.getSession()?.userToken else {
//            return .error(SignError.tokenNotFound)
//        }
//
//        let request = SaveInteractionDrugsRequest(userToken: userToken, id: interactionId)
//
//        return defaultRequestWrapper
//            .callServerApi(requestBody: request)
//            .map { SaveUnsaveInteractionDrugsResponse.map(from: $0) }
//            .do(onSuccess: { success in
//                guard success else {
//                    return
//                }
//
//                DrugsMediator.shared.saveInteraction(id: interactionId)
//            })
//    }
//
//    func unsave(interactionsIds: [Int]) -> Single<Bool> {
//        guard let userToken = sessionManager.getSession()?.userToken else {
//            return .error(SignError.tokenNotFound)
//        }
//
//        let request = UnsaveInteractionDrugsRequest(userToken: userToken, ids: interactionsIds)
//
//        return defaultRequestWrapper
//            .callServerApi(requestBody: request)
//            .map { SaveUnsaveInteractionDrugsResponse.map(from: $0) }
//            .do(onSuccess: { success in
//                guard success else {
//                    return
//                }
//
//                DrugsMediator.shared.unsaveInteractions(ids: interactionsIds)
//            })
//    }
//
//    func obtainBookmarksInteractions() -> Single<[DrugsInteraction]> {
//        guard let userToken = sessionManager.getSession()?.userToken else {
//            return .error(SignError.tokenNotFound)
//        }
//
//        let request = GetBookmarksInteractionsRequest(userToken: userToken)
//
//        return defaultRequestWrapper
//            .callServerApi(requestBody: request)
//            .map { GetBookmarksInteractionsResponse.map(from: $0) }
//    }
//}
//
//// MARK: Private
//private extension DrugsManager {
//    func loadDrugs() -> Single<[Drug]> {
//        guard let userToken = sessionManager.getSession()?.userToken else {
//            return .error(SignError.tokenNotFound)
//        }
//
//        let request = GetDrugsRequest(userToken: userToken, search: nil)
//
//        return defaultRequestWrapper
//            .callServerApi(requestBody: request)
//            .map { GetDrugsResponse.map(from: $0) }
//            .do(onSuccess: { drugs in
//                guard let data = try? JSONEncoder().encode(drugs) else {
//                    return
//                }
//
//                UserDefaults.standard.set(data, forKey: Constants.drugs)
//            })
//    }
//
//    func cachedDrugs() -> Single<[Drug]> {
//        Single<[Drug]>.create { event in
//            guard
//                let data = UserDefaults.standard.data(forKey: Constants.drugs),
//                let drugs = try? JSONDecoder().decode([Drug].self, from: data)
//            else {
//                event(.success([]))
//                return Disposables.create()
//            }
//
//            event(.success(drugs))
//
//            return Disposables.create()
//        }
//    }
//}
