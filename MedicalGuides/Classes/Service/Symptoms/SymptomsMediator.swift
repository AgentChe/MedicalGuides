//
//  SymptomsMediator.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

import RxSwift
import RxCocoa

final class SymptomsMediator {
    static let shared = SymptomsMediator()
    
    private lazy var didSaveConditionIdTrigger = PublishRelay<Int>()
    private lazy var didUnsaveConditionsIdsTrigger = PublishRelay<[Int]>()
    
    private init() {}
}

// MARK: Public
extension SymptomsMediator {
    func saveCondition(id: Int) {
        DispatchQueue.main.async {
            Self.shared.didSaveConditionIdTrigger.accept(id)
        }
    }
    
    func unsaveConditions(ids: [Int]) {
        DispatchQueue.main.async {
            Self.shared.didUnsaveConditionsIdsTrigger.accept(ids)
        }
    }
    
    var didSaveConditionId: Signal<Int> {
        didSaveConditionIdTrigger.asSignal()
    }
    
    var didUnsaveConditionsIds: Signal<[Int]> {
        didUnsaveConditionsIdsTrigger.asSignal()
    }
}
