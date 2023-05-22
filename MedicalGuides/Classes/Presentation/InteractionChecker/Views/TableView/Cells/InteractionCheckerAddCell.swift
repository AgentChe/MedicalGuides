//
//  InteractionCheckerAddCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

import UIKit

final class InteractionCheckerAddCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()
    
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
private extension InteractionCheckerAddCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension InteractionCheckerAddCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.scale),
            container.heightAnchor.constraint(equalToConstant: 55.scale)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 19.scale),
            iconView.heightAnchor.constraint(equalToConstant: 20.scale),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 96.5.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10.scale),
            label.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension InteractionCheckerAddCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.primary.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "InteractionChecker.Add")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.primary)
            .font(Fonts.Avenir.bold(size: 15.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "InteractionChecker.AddMore".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
