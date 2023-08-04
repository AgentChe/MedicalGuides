//
//  SCResultConditionCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 31.05.2023.
//

import UIKit

final class SCResultConditionCell: UITableViewCell {
    var didTapReadMore: (() -> Void)?
    
    lazy var container = makeContainer()
    lazy var nameLabel = makeLabel()
    lazy var fairMatchLabel = makeFairMatchLabel()
    lazy var readMoreButton = makeReadMoreButton()
    lazy var level1View = makeLevelView()
    lazy var level2View = makeLevelView()
    lazy var level3View = makeLevelView()
    lazy var level4View = makeLevelView()
    
    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.bold(size: 21.scale))
        .textAlignment(.left)
    private lazy var fairMatchAttrs = TextAttributes()
        .textColor(Appearance.black.withAlphaComponent(0.5))
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
extension SCResultConditionCell {
    func setup(element: SymptomsInteractionCondition) {
        nameLabel.attributedText = element.name.attributed(with: nameAttrs)
        fairMatchLabel.attributedText = title(for: element.fairMatch).attributed(with: fairMatchAttrs)
        
        let levelViews = [
            level1View,
            level2View,
            level3View,
            level4View
        ]
        levelViews.forEach { $0.backgroundColor = Appearance.black.withAlphaComponent(0.1) }
        
        let selectedColor = color(for: element.fairMatch)
        levelViews.prefix(element.fairMatch).forEach { $0.backgroundColor = selectedColor }
    }
}

// MARK: Private
private extension SCResultConditionCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func readMoreTapped() {
        didTapReadMore?()
    }
    
    func title(for fairMatch: Int) -> String {
        switch fairMatch {
        case 1:
            return "SymptomChecker.Result.Low".localized
        case 2:
            return "SymptomChecker.Result.Fair".localized
        case 3:
            return "SymptomChecker.Result.Moderate".localized
        case 4:
            return "SymptomChecker.Result.StrongMatch".localized
        default:
            return "SymptomChecker.Result.StrongMatch".localized
        }
    }
    
    func color(for fairMatch: Int) -> UIColor {
        switch fairMatch {
        case 1:
            return Appearance.secondary2
        case 2:
            return Appearance.secondary3
        case 3:
            return Appearance.primary
        case 4:
            return Appearance.secondary1
        default:
            return Appearance.secondary1
        }
    }
}

// MARK: Make constraints
private extension SCResultConditionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 143.scale)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            fairMatchLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            fairMatchLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 78.scale)
        ])
        
        NSLayoutConstraint.activate([
            readMoreButton.widthAnchor.constraint(equalToConstant: 120.scale),
            readMoreButton.heightAnchor.constraint(equalToConstant: 45.scale),
            readMoreButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale),
            readMoreButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 78.scale)
        ])
        
        NSLayoutConstraint.activate([
            level1View.widthAnchor.constraint(equalToConstant: 32.scale),
            level1View.heightAnchor.constraint(equalToConstant: 3.scale),
            level1View.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            level1View.topAnchor.constraint(equalTo: fairMatchLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            level2View.widthAnchor.constraint(equalToConstant: 32.scale),
            level2View.heightAnchor.constraint(equalToConstant: 3.scale),
            level2View.leadingAnchor.constraint(equalTo: level1View.trailingAnchor, constant: 10.scale),
            level2View.centerYAnchor.constraint(equalTo: level1View.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            level3View.widthAnchor.constraint(equalToConstant: 32.scale),
            level3View.heightAnchor.constraint(equalToConstant: 3.scale),
            level3View.leadingAnchor.constraint(equalTo: level2View.trailingAnchor, constant: 10.scale),
            level3View.centerYAnchor.constraint(equalTo: level1View.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            level4View.widthAnchor.constraint(equalToConstant: 32.scale),
            level4View.heightAnchor.constraint(equalToConstant: 3.scale),
            level4View.leadingAnchor.constraint(equalTo: level3View.trailingAnchor, constant: 10.scale),
            level4View.centerYAnchor.constraint(equalTo: level1View.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SCResultConditionCell {
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
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeFairMatchLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeReadMoreButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.Avenir.regular(size: 15.scale))
            .textAlignment(.center)
        
        let view = UIButton()
        view.setAttributedTitle("SymptomChecker.Result.ReadMore".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary
        view.layer.cornerRadius = 8.scale
        view.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLevelView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}

