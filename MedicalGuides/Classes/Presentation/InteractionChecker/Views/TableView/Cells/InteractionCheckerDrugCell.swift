//
//  InteractionCheckerDrugCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

import UIKit

final class InteractionCheckerDrugCell: UITableViewCell {
    lazy var numberLabel = makeLabel()
    lazy var modeContainer = makeModeContainer()
    lazy var modeLabel = makeLabel()
    
    private lazy var numberAttrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.bold(size: 21.scale))
        .lineHeight(28.69.scale)
        .textAlignment(.left)
    private lazy var chooseAttrs = TextAttributes()
        .textColor(Appearance.black.withAlphaComponent(0.3))
        .font(Fonts.Avenir.regular(size: 15.scale))
        .lineHeight(21.scale)
        .textAlignment(.left)
    private lazy var drugAttrs = TextAttributes()
        .textColor(Appearance.black)
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
extension InteractionCheckerDrugCell {
    func setup(element: InteractionCheckerDrugElement) {
        let number = String(format: "InteractionChecker.Drug.Number".localized, element.number)
        numberLabel.attributedText = number.attributed(with: numberAttrs)
        
        switch element.mode {
        case .choose:
            modeLabel.attributedText = "InteractionChecker.ChooseDrug".localized.attributed(with: chooseAttrs)
        case .drug(let drug):
            modeLabel.attributedText = drug.name.attributed(with: drugAttrs)
        }
    }
}

// MARK: Private
private extension InteractionCheckerDrugCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension InteractionCheckerDrugCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            numberLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            modeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            modeContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            modeContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 51.scale),
            modeContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.scale)
        ])
        
        NSLayoutConstraint.activate([
            modeLabel.leadingAnchor.constraint(equalTo: modeContainer.leadingAnchor, constant: 20.scale),
            modeLabel.trailingAnchor.constraint(equalTo: modeContainer.trailingAnchor, constant: -20.scale),
            modeLabel.topAnchor.constraint(equalTo: modeContainer.topAnchor, constant: 18.scale),
            modeLabel.bottomAnchor.constraint(equalTo: modeContainer.bottomAnchor, constant: -18.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension InteractionCheckerDrugCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeModeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
