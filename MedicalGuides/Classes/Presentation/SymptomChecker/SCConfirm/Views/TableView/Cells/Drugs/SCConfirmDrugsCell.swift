//
//  SCConfirmDrugsCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 31.05.2023.
//

import UIKit

final class SCConfirmDrugsCell: UITableViewCell {
    lazy var tagsView = makeTagsView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SCConfirmDrugsCell {
    func setup(element: [SymptomMed]) {
        tagsView.removeAllTags()
        tagsView.addTags(element.map { .symptomMed($0) })
    }
    
    func setup(element: [MedicalState]) {
        tagsView.removeAllTags()
        tagsView.addTags(element.map { .medicalState($0) })
    }
}

// MARK: Private
private extension SCConfirmDrugsCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension SCConfirmDrugsCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tagsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            tagsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            tagsView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.scale),
            tagsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SCConfirmDrugsCell {
    func makeTagsView() -> DrugTagsView {
        let view = DrugTagsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
