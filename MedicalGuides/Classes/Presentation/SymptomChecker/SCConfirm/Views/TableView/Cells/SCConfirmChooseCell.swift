//
//  SCConfirmChooseCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 29.05.2023.
//

import UIKit

final class SCConfirmChooseCell: UITableViewCell {
    var didSelect: (() -> Void)?
    
    lazy var titleLabel = makeTitleLabel()
    lazy var container = makeContainer()
    lazy var placeholderLabel = makePlaceholerLabel()
    
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.bold(size: 21.scale))
        .textAlignment(.left)
    private lazy var placeholderAttrs = TextAttributes()
        .textColor(Appearance.black.withAlphaComponent(0.3))
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
extension SCConfirmChooseCell {
    func setup(element: SCConfirmChooseElement) {
        switch element {
        case .currentMedications:
            titleLabel.attributedText = "SymptomChecker.Confirm.CurrentMedications".localized.attributed(with: titleAttrs)
            placeholderLabel.attributedText = "SymptomChecker.Confirm.ChooseDrug".localized.attributed(with: placeholderAttrs)
        case .conditions:
            titleLabel.attributedText = "SymptomChecker.Confirm.Conditions".localized.attributed(with: titleAttrs)
            placeholderLabel.attributedText = "SymptomChecker.Confirm.ChooseCondition".localized.attributed(with: placeholderAttrs)
        }
    }
}

// MARK: Private
private extension SCConfirmChooseCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func tapped() {
        didSelect?()
    }
}

// MARK: Make constraints
private extension SCConfirmChooseCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.scale),
            container.heightAnchor.constraint(equalToConstant: 55.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            placeholderLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SCConfirmChooseCell {
    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 10.scale
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makePlaceholerLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
