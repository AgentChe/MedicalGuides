//
//  HomeTableCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 12.05.2023.
//

import UIKit

final class HomeTableCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var iconView = makeIconView()
    lazy var titleLabel = makeLabel()
    lazy var descriptionLabel = makeLabel()
    
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.black(size: 21.scale))
    private lazy var textAttrs = TextAttributes()
        .textColor(Appearance.black.withAlphaComponent(0.5))
        .font(Fonts.Avenir.regular(size: 15.scale))
        .lineHeight(21.scale)
    
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
extension HomeTableCell {
    func setup(element: HomeTableElement) {
        iconView.image = UIImage(named: element.imageName)
        
        titleLabel.attributedText = element.title.attributed(with: titleAttrs)
        descriptionLabel.attributedText = element.text.attributed(with: textAttrs)
    }
}

// MARK: Private
private extension HomeTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension HomeTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.scale)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 109.scale),
            iconView.heightAnchor.constraint(equalToConstant: 178.scale),
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 113.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 113.scale),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeTableCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 8.scale
        view.backgroundColor = Appearance.white
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
