//
//  DrugsMockManager.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 17.05.2023.
//

import RxSwift

// TODO: временно
final class DrugsManager: DrugsManagerProtocol {
    func obtainDrugs(forceUpdate: Bool) -> Single<[Drug]> {
        Single<[Drug]>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            let drugs = self.drugs()
            event(.success(drugs))
            
            return Disposables.create()
        }
    }
    
    func obtainDrugDetails(id: Int) -> Single<DrugDetails?> {
        Single<DrugDetails?>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                DispatchQueue.main.async {
                    let drugDetails = self.drugDetails(id: id)
                    event(.success(drugDetails))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func save(drugId: Int) -> Single<Bool> {
        Single<Bool>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            self.saveDrug(drugId: drugId)
            event(.success(true))
            
            DrugsMediator.shared.saveDrug(id: drugId)
            
            return Disposables.create()
        }
    }
    
    func unsave(drugsIds: [Int]) -> Single<Bool> {
        Single<Bool>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            self.unsaveDrugs(drugIds: drugsIds)
            event(.success(true))
            
            DrugsMediator.shared.unsaveDrugs(ids: drugsIds)
            
            return Disposables.create()
        }
    }
    
    func obtainBookmarksDrugs() -> Single<[Drug]> {
        Single<[Drug]>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            let drugs = self.savedDrugs()
            event(.success(drugs))
            
            return Disposables.create()
        }
    }
    
    func interactionCheck(drugsIds: [Int]) -> Single<DrugsInteraction?> {
        Single<DrugsInteraction?>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                DispatchQueue.main.async {
                    let interaction = self.checkDrugsIds(ids: drugsIds)
                    event(.success(interaction))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func save(interactionId: Int) -> Single<Bool> {
        Single<Bool>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            self.saveInteraction(id: interactionId)
            event(.success(true))
            
            DrugsMediator.shared.saveInteraction(id: interactionId)
            
            return Disposables.create()
        }
    }
    
    func unsave(interactionsIds: [Int]) -> Single<Bool> {
        Single<Bool>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            self.unsaveInteractions(ids: interactionsIds)
            event(.success(true))
            
            DrugsMediator.shared.unsaveInteractions(ids: interactionsIds)
            
            return Disposables.create()
        }
    }
    
    func obtainBookmarksInteractions() -> Single<[DrugsInteraction]> {
        Single<[DrugsInteraction]>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            let interactions = self.savedInteractions()
            event(.success(interactions))
            
            return Disposables.create()
        }
    }
}

// MARK: Private
private extension DrugsManager {
    func drugs() -> [Drug] {
        let saved = savedDrugs()
        
        var result = [Drug]()
        
        for i in 0...100 {
            let drug = Drug(
                id: i,
                name: "Antianemics \(i)",
                saved: saved.contains(where: { $0.id == i })
            )
            result.append(drug)
        }
        
        return result
    }
    
    func drugDetails(id: Int) -> DrugDetails? {
        let drugs = drugs()
        
        guard let drug = drugs.first(where: { $0.id == id }) else {
            return nil
        }
        
        return DrugDetails(
            id: drug.id,
            name: drug.name,
            saved: drug.saved,
            sections: [
                .init(name: "Ibuprofen",
                      blocks: [
                        .init(title: "Uses",
                              text: "Ibuprofen is used to relieve pain from various conditions such as headache, dental pain, menstrual cramps, muscle aches, or arthritis. It is also used to reduce fever and to relieve minor aches and pain due to the common cold or flu. Ibuprofen is a nonsteroidal anti-inflammatory drug (NSAID). It works by blocking your body's production of certain natural substances that cause inflammation. This effect helps to decrease swelling, pain, or fever.If you are treating a chronic condition such as arthritis, ask your doctor about non-drug treatments and/or using other medications to treat your pain. See also Warning section."),
                        .init(title: "How to use ibuprofen oral",
                              text: "If you are taking the over-the-counter product, read all directions on the product package before taking this medication. If your doctor has prescribed this medication, read the Medication Guide provided by your pharmacist before you start taking ibuprofen and each time you get a refill. If you have any questions, ask your doctor or pharmacist.")
                      ]),
                .init(name: "Side Effects",
                      blocks: [
                        .init(title: nil,
                              text: "If you are taking the over-the-counter product, read all directions on the product package before taking this medication. If your doctor has prescribed this medication, read the Medication Guide provided by your pharmacist before you start taking ibuprofen and each time you get a refill. If you have any questions, ask your doctor or pharmacist.")
                      ])
            ]
        )
    }
    
    func saveDrug(drugId: Int) {
        var saved = savedDrugs()
        let drugs = drugs()
        
        guard let drug = drugs.first(where: { $0.id == drugId }) else {
            return
        }
        
        let updated = Drug(
            id: drug.id,
            name: drug.name,
            saved: true
        )
        
        saved.append(updated)
        
        guard let data = try? JSONEncoder().encode(saved) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: "saved_drugs")
    }
    
    func unsaveDrugs(drugIds: [Int]) {
        var saved = savedDrugs()
        
        saved.removeAll(where: { drug -> Bool in
            drugIds.contains(where: { drug.id == $0 })
        })
        
        guard let data = try? JSONEncoder().encode(saved) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: "saved_drugs")
    }
    
    func savedDrugs() -> [Drug] {
        guard
            let data = UserDefaults.standard.data(forKey: "saved_drugs"),
            let drugs = try? JSONDecoder().decode([Drug].self, from: data)
        else {
            return []
        }
        
        return drugs
    }
    
    func checkDrugsIds(ids: [Int]) -> DrugsInteraction? {
        let saved = savedInteractions()
        let drugs = drugs()
        
        let id = ids.reduce(0) { $0 + $1 }
        let title = drugs
            .filter { drug in ids.contains(where: { $0 == drug.id }) }
            .reduce("") { $0 + " + \($1.name)" }
        
        let interaction = DrugsInteraction(
            id: id,
            drugsIds: ids,
            title: title,
            subtitle: "Interaction is unlikely, minor, or nonsignificant.",
            text: "Ibuprofen will increase the level or effect of Acyclovir by acidic drugs competing for the same pathway through the kidney.",
            sideEffect: .minor,
            saved: saved.contains(where: { $0.id == id })
        )
        
        if let data = UserDefaults.standard.data(forKey: "drugs_interactions"), var interactions = try? JSONDecoder().decode([DrugsInteraction].self, from: data) {
            interactions.append(interaction)
            if let updatedData = try? JSONEncoder().encode(interactions) {
                UserDefaults.standard.set(updatedData, forKey: "drugs_interactions")
            }
        } else {
            if let updatedData = try? JSONEncoder().encode([interaction]) {
                UserDefaults.standard.set(updatedData, forKey: "drugs_interactions")
            }
        }
        
        return interaction
    }
    
    func interactions() -> [DrugsInteraction] {
        guard
            let data = UserDefaults.standard.data(forKey: "drugs_interactions"),
            let interactions = try? JSONDecoder().decode([DrugsInteraction].self, from: data)
        else {
            return []
        }
        
        return interactions
    }
    
    func savedInteractions() -> [DrugsInteraction] {
        guard
            let data = UserDefaults.standard.data(forKey: "saved_interactions"),
            let interactions = try? JSONDecoder().decode([DrugsInteraction].self, from: data)
        else {
            return []
        }
        
        return interactions
    }
    
    func saveInteraction(id: Int) {
        var saved = savedInteractions()
        let interactions = interactions()
        
        guard let interaction = interactions.first(where: { $0.id == id }) else {
            return
        }
        
        let updated = DrugsInteraction(
            id: interaction.id,
            drugsIds: interaction.drugsIds,
            title: interaction.title,
            subtitle: interaction.subtitle,
            text: interaction.text,
            sideEffect: interaction.sideEffect,
            saved: true
        )
        
        saved.append(updated)
        
        guard let data = try? JSONEncoder().encode(saved) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: "saved_interactions")
    }
    
    func unsaveInteractions(ids: [Int]) {
        var saved = savedInteractions()
        
        saved.removeAll(where: { interaction -> Bool in
            ids.contains(where: { interaction.id == $0 })
        })
        
        guard let data = try? JSONEncoder().encode(saved) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: "saved_interactions")
    }
}
