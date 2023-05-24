//
//  DrugTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

final class DrugTableSection {
    var opened: Bool
    let openedElements: [DrugTableElement]
    let closedElements: [DrugTableElement]
    
    init(
        opened: Bool,
        openedElements: [DrugTableElement],
        closedElements: [DrugTableElement]
    ) {
        self.opened = opened
        self.openedElements = openedElements
        self.closedElements = closedElements
    }
}

enum DrugTableElement {
    case name(String)
    case section(DrugSectionElement)
    case title(String)
    case text(String)
    case separator
}

final class DrugSectionElement {
    let name: String
    var opened: Bool
    
    init(name: String, opened: Bool) {
        self.name = name
        self.opened = opened
    }
}
