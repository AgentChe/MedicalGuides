//
//  BookmarkTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

final class BookmarkTableElement {
    enum Unit {
        case drug(Drug)
        case interaction(BookmarkInteractionElement)
        case condition(SymptomsInteractionConditionDetails)
    }
    
    let unit: Unit
    var seleted: Bool?
    
    init(
        unit: Unit,
        seleted: Bool?
    ) {
        self.unit = unit
        self.seleted = seleted
    }
}

struct BookmarkInteractionElement {
    let interaction: DrugsInteraction
    let meds: [InteractionCheckerMed]
}
