//
//  SICDetailsTextCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 01.06.2023.
//

import UIKit

final class SICDetailsTextCell: UITableViewCell {
    lazy var label = makeLabel()
    
    private lazy var attrs = TextAttributes()
        .textColor(UIColor(integralRed: 84, green: 84, blue: 84))
        .font(Fonts.Avenir.regular(size: 15.scale))
        .lineHeight(21.scale)
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
extension SICDetailsTextCell {
    func setup(element: String) {
        label.attributedText = element.attributed(with: attrs)
    }
}

// MARK: Private
private extension SICDetailsTextCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension SICDetailsTextCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SICDetailsTextCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
