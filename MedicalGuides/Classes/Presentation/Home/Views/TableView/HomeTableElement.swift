//
//  HomeTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 12.05.2023.
//

struct HomeTableElement {
    enum Block {
        case drugGuide, interactionChecker, symptomChecker, bookmark
    }
    
    let block: Block
    let title: String
    let text: String
    let imageName: String
    
    init(block: Block) {
        self.block = block
        
        switch block {
        case .drugGuide:
            title = "Home.DrugGuide.Title".localized
            text = "Home.DrugGuide.Text".localized
            imageName = "Home.DrugGuide"
        case .interactionChecker:
            title = "Home.InteractionChecker.Title".localized
            text = "Home.InteractionChecker.Text".localized
            imageName = "Home.InteractionChecker"
        case .symptomChecker:
            title = "Home.SymptomChecker.Title".localized
            text = "Home.SymptomChecker.Text".localized
            imageName = "Home.SymptomChecker"
        case .bookmark:
            title = "Home.Bookmark.Title".localized
            text = "Home.Bookmark.Text".localized
            imageName = "Home.Bookmark"
        }
    }
}
