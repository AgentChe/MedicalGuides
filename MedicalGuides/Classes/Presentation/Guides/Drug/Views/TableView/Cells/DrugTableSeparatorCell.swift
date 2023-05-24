//
//  DrugTableSeparatorCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import UIKit

final class DrugTableSeparatorCell: UITableViewCell {
    lazy var separator = makeSeparator()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension DrugTableSeparatorCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DrugTableSeparatorCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale),
            separator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DrugTableSeparatorCell {
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.black.withAlphaComponent(0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
