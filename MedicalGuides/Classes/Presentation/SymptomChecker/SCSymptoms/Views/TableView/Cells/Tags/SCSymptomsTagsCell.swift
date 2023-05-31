//
//  SCSymptomsTagsCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 25.05.2023.
//

import UIKit

final class SCSymptomsTagsCell: UITableViewCell {
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
extension SCSymptomsTagsCell {
    func setup(element: [Symptom]) {
        tagsView.removeAllTags()
        tagsView.addTags(element.map { $0 })
    }
}

// MARK: Private
private extension SCSymptomsTagsCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension SCSymptomsTagsCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tagsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            tagsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            tagsView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.scale),
            tagsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SCSymptomsTagsCell {
    func makeTagsView() -> SymptomTagsView {
        let view = SymptomTagsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
