//
//  DrugTableSectionCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import UIKit

final class DrugTableSectionCell: UITableViewCell {
    lazy var label = makeLabel()
    lazy var iconView = makeIconView()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.bold(size: 21.scale))
        .textAlignment(.left)
    
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
extension DrugTableSectionCell {
    func setup(element: DrugSectionElement) {
        label.attributedText = element.name.attributed(with: attrs)
        
        let iconName = element.opened ? "Drug.Arrow.Down" : "Drug.Arrow.Up" 
        iconView.image = UIImage(named: iconName)
    }
}

// MARK: Private
private extension DrugTableSectionCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DrugTableSectionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -46.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 17.scale),
            iconView.heightAnchor.constraint(equalToConstant: 17.scale),
            iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DrugTableSectionCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
