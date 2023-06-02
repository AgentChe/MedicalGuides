//
//  SICDetailsTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 01.06.2023.
//

final class SICDetailsTableSection {
    var opened: Bool
    let openedElements: [SICDetailsTableElement]
    let closedElements: [SICDetailsTableElement]
    
    init(
        opened: Bool,
        openedElements: [SICDetailsTableElement],
        closedElements: [SICDetailsTableElement]
    ) {
        self.opened = opened
        self.openedElements = openedElements
        self.closedElements = closedElements
    }
}

enum SICDetailsTableElement {
    case section(SICDetailsSectionElement)
    case text(String)
    case separator
}

final class SICDetailsSectionElement {
    let name: String
    var opened: Bool
    
    init(name: String, opened: Bool) {
        self.name = name
        self.opened = opened
    }
}
