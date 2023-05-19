//
//  SymptomsMockManager.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

import RxSwift

final class SymptomsManager: SymptomsManagerProtocol {
    func obtainSymptoms(forceUpdate: Bool) -> Single<[Symptom]> {
        Single<[Symptom]>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            let symptoms = self.symptoms()
            event(.success(symptoms))
            
            return Disposables.create()
        }
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
        Single<[SymptomsInteractionCondition]>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            let conditions = self.check(age: age, symptomsIds: symptomsIds)
            event(.success(conditions))
            
            return Disposables.create()
        }
    }
    
    func obtainConditionDetails(id: Int) -> Single<SymptomsInteractionConditionDetails?> {
        Single<SymptomsInteractionConditionDetails?>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            let details = self.conditionDetails(id: id)
            event(.success(details))
            
            return Disposables.create()
        }
    }
    
    func save(conditionId: Int) -> Single<Bool> {
        Single<Bool>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            self.saveCondition(conditionId: conditionId)
            event(.success(true))
            
            SymptomsMediator.shared.saveCondition(id: conditionId)
            
            return Disposables.create()
        }
    }
    
    func unsave(conditionsIds: [Int]) -> Single<Bool> {
        Single<Bool>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            self.unsaveConditions(conditionsIds: conditionsIds)
            event(.success(true))
            
            SymptomsMediator.shared.unsaveConditions(ids: conditionsIds)
            
            return Disposables.create()
        }
    }
    
    func obtainBookmarksConditions() -> Single<[SymptomsInteractionCondition]> {
        Single<[SymptomsInteractionCondition]>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            let conditions = self.savedConditions()
            event(.success(conditions))
            
            return Disposables.create()
        }
    }
}

// MARK: Private
private extension SymptomsManager {
    func symptoms() -> [Symptom] {
        var symptoms = [Symptom]()
        
        for i in 0...100 {
            let symptom = Symptom(
                id: i,
                name: "Toothache \(i)"
            )
            symptoms.append(symptom)
        }
        
        return symptoms
    }
    
    func check(age: Int, symptomsIds: [Int]) -> [SymptomsInteractionCondition] {
        let saved = savedConditions()
        
        let id1 = symptomsIds.reduce(0) { $0 + $1 } + age
        let id2 = symptomsIds.reduce(0) { $0 + $1 } + age + 1
        
        let conditions: [SymptomsInteractionCondition] = [
            .init(id: id1,
                  name: "Benign Paroxysmal Positional Vertigo",
                  saved: saved.contains(where: { $0.id == id1 }),
                  fairMatch: Int.random(in: 1...4)),
            .init(id: id2,
                  name: "Benign Paroxysmal Positional Vertigo",
                  saved: saved.contains(where: { $0.id == id2 }),
                  fairMatch: Int.random(in: 1...4)),
        ]
        
        if let data = UserDefaults.standard.data(forKey: "created_conditions"), var created = try? JSONDecoder().decode([SymptomsInteractionCondition].self, from: data) {
            created += conditions
            if let updatedData = try? JSONEncoder().encode(created) {
                UserDefaults.standard.set(updatedData, forKey: "created_conditions")
            }
        } else {
            if let updatedData = try? JSONEncoder().encode(conditions) {
                UserDefaults.standard.set(updatedData, forKey: "created_conditions")
            }
        }
        
        return conditions
    }
    
    func createdConditions() -> [SymptomsInteractionCondition] {
        guard
            let data = UserDefaults.standard.data(forKey: "created_conditions"),
            let conditions = try? JSONDecoder().decode([SymptomsInteractionCondition].self, from: data)
        else {
            return []
        }
        
        return conditions
    }
    
    func savedConditions() -> [SymptomsInteractionCondition] {
        guard
            let data = UserDefaults.standard.data(forKey: "saved_conditions"),
            let conditions = try? JSONDecoder().decode([SymptomsInteractionCondition].self, from: data)
        else {
            return []
        }
        
        return conditions
    }
    
    func conditionDetails(id: Int) -> SymptomsInteractionConditionDetails {
        let saved = savedConditions()
        
        return SymptomsInteractionConditionDetails(
            id: id,
            saved: saved.contains(where: { $0.id == id }),
            details: [
                .init(title: "Symptoms",
                      text: "Dizziness, loss of balance, a sensation of spinning or moving when you are still, nausea, vomiting, headache, hearing loss, difficulty concentrating, and ringing in the ears (tinnitus)"),
                .init(title: "How Common",
                      text: "About 17% of people with chronic ear infections develop labyrinthitis. And about one in 10,000 people seek treatment for sudden labyrinthitis, often after a cold or flu.")
            ],
            treatmentOptions: [
                .init(title: "Take Care Of Yourself",
                      text: "Dizziness, loss of balance, a sensation of spinning or moving when you are still, nausea, vomiting, headache, hearing loss, difficulty concentrating, and ringing in the ears (tinnitus)"),
                .init(title: "Made Worse By",
                      text: "About 17% of people with chronic ear infections develop labyrinthitis. And about one in 10,000 people seek treatment for sudden labyrinthitis, often after a cold or flu.")
            ]
        )
    }
    
    func saveCondition(conditionId: Int) {
        var saved = savedConditions()
        let conditions = createdConditions()
        
        guard let condition = conditions.first(where: { $0.id == conditionId }) else {
            return
        }
        
        let updated = SymptomsInteractionCondition(
            id: condition.id,
            name: condition.name,
            saved: true,
            fairMatch: condition.fairMatch
        )
        
        saved.append(updated)
        
        guard let data = try? JSONEncoder().encode(saved) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: "saved_conditions")
    }
    
    func unsaveConditions(conditionsIds: [Int]) {
        var saved = savedConditions()
        
        saved.removeAll(where: { condition -> Bool in
            conditionsIds.contains(where: { condition.id == $0 })
        })
        
        guard let data = try? JSONEncoder().encode(saved) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: "saved_conditions")
    }
}
