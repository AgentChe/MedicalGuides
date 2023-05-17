//
//  DrugsMediator.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

import RxSwift
import RxCocoa

final class DrugsMediator {
    static let shared = DrugsMediator()
    
    private lazy var didSaveDrugIdTrigger = PublishRelay<Int>()
    private lazy var didUnsaveDrugsIdsTrigger = PublishRelay<[Int]>()
    private lazy var didSaveInteractionIdTrigger = PublishRelay<Int>()
    private lazy var didUnsaveInteractionsIdsTrigger = PublishRelay<[Int]>()
    
    private init() {}
}

// MARK: Public
extension DrugsMediator {
    func saveDrug(id: Int) {
        DispatchQueue.main.async {
            Self.shared.didSaveDrugIdTrigger.accept(id)
        }
    }
    
    func unsaveDrugs(ids: [Int]) {
        DispatchQueue.main.async {
            Self.shared.didUnsaveDrugsIdsTrigger.accept(ids)
        }
    }
    
    func saveInteraction(id: Int) {
        DispatchQueue.main.async {
            Self.shared.didSaveInteractionIdTrigger.accept(id)
        }
    }
    
    func unsaveInteractions(ids: [Int]) {
        DispatchQueue.main.async {
            Self.shared.didUnsaveInteractionsIdsTrigger.accept(ids)
        }
    }
    
    var didSaveDrugId: Signal<Int> {
        didSaveDrugIdTrigger.asSignal()
    }
    
    var didUnsaveDrugsIds: Signal<[Int]> {
        didUnsaveDrugsIdsTrigger.asSignal()
    }
    
    var didSaveInteractionId: Signal<Int> {
        didSaveInteractionIdTrigger.asSignal()
    }
    
    var didUnsaveInteractionsIds: Signal<[Int]> {
        didUnsaveInteractionsIdsTrigger.asSignal()
    }
}
