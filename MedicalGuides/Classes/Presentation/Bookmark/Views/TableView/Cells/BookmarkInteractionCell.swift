//
//  BookmarkInteractionCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import UIKit

final class BookmarkInteractionCell: UITableViewCell {
    lazy var checkedView = makeCheckedView()
    lazy var container = makeContainer()
    lazy var namesLabel = makeLabel()
    lazy var sideEffectLabel = makeLabel()
    lazy var dashView = makeDashView()
    
    private lazy var containerLeadingConstraint = NSLayoutConstraint()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.bold(size: 21.scale))
        .lineHeight(28.69.scale)
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
extension BookmarkInteractionCell {
    func setup(interaction: BookmarkInteractionElement, selected: Bool?) {
        let names = interaction.meds
            .map { $0.name }
            .joined(separator: " + ")
        namesLabel.attributedText = names.attributed(with: attrs)
        
        let sideEffectColor = color(at: interaction.interaction.sideEffect)
        let sideEffectAttrs = TextAttributes()
            .textColor(sideEffectColor)
            .font(Fonts.Avenir.bold(size: 21.scale))
            .lineHeight(28.69.scale)
            .textAlignment(.left)
        sideEffectLabel.attributedText = name(at: interaction.interaction.sideEffect).attributed(with: sideEffectAttrs)
        dashView.backgroundColor = sideEffectColor
        
        checkedView.image = UIImage(named: selected == true ? "Bookmark.Checked" : "Bookmark.Unchecked")
        checkedView.isHidden = selected == nil
        
        containerLeadingConstraint.isActive = false
        containerLeadingConstraint.constant = selected == nil ? 16.scale : 42.scale
        containerLeadingConstraint.isActive = true
        
        layoutIfNeeded()
    }
}

// MARK: Private
private extension BookmarkInteractionCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    func color(at sideEffect: DrugsSideEffect) -> UIColor {
        switch sideEffect {
        case .minor:
            return Appearance.secondary1
        case .monitorClosely:
            return Appearance.primary
        case .serious:
            return Appearance.secondary2
        case .dontUseTogether:
            return UIColor(integralRed: 198, green: 42, blue: 80)
        }
    }
    
    func name(at sideEffect: DrugsSideEffect) -> String {
        switch sideEffect {
        case .minor:
            return "Bookmark.SideEffect.Minor".localized
        case .monitorClosely:
            return "Bookmark.SideEffect.MonitorClosely".localized
        case .serious:
            return "Bookmark.SideEffect.Serious".localized
        case .dontUseTogether:
            return "Bookmark.SideEffect.DontUseTogether".localized
        }
    }
}

// MARK: Make constraints
private extension BookmarkInteractionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            checkedView.widthAnchor.constraint(equalToConstant: 18.scale),
            checkedView.heightAnchor.constraint(equalToConstant: 19.scale),
            checkedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            checkedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        containerLeadingConstraint = container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale)
        NSLayoutConstraint.activate([
            containerLeadingConstraint,
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            namesLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            namesLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale),
            namesLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            sideEffectLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 52.scale),
            sideEffectLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale),
            sideEffectLabel.topAnchor.constraint(equalTo: namesLabel.bottomAnchor, constant: 12.scale),
            sideEffectLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24.scale)
        ])
        
        NSLayoutConstraint.activate([
            dashView.widthAnchor.constraint(equalToConstant: 20.scale),
            dashView.heightAnchor.constraint(equalToConstant: 3.scale),
            dashView.centerYAnchor.constraint(equalTo: sideEffectLabel.centerYAnchor),
            dashView.trailingAnchor.constraint(equalTo: sideEffectLabel.leadingAnchor, constant: -12.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension BookmarkInteractionCell {
    func makeCheckedView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 20.scale
        view.backgroundColor = Appearance.white
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeDashView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
