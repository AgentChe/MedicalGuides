//
//  SettingsTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.05.2023.
//

struct SettingsTableSection {
    let elements: [SettingsTableElement]
}

enum SettingsTableElement {
    case route(SettingsRoute)
}

enum SettingsRoute {
    case disclaimer, contactUs, termsOfUse, privacyPolicy
}
