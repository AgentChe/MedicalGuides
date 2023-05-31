//
//  SCConfirmPregnantCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 29.05.2023.
//

import UIKit

final class SCConfirmPregnantCell: UITableViewCell {
    var didSelect: ((Bool) -> Void)?
    
    lazy var titleLabel = makeTitleLabel()
    lazy var pregnantView = makePregnantView()
    
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
private extension SCConfirmPregnantCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func noTapped() {
        setup(pregnant: false)
    }
    
    @objc
    func yesTapped() {
        setup(pregnant: true)
    }
    
    func setup(pregnant: Bool) {
        pregnantView.pregnant = pregnant
        
        didSelect?(pregnant)
    }
}

// MARK: Make constraints
private extension SCConfirmPregnantCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            pregnantView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            pregnantView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            pregnantView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.scale),
            pregnantView.heightAnchor.constraint(equalToConstant: 45.scale),
            pregnantView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SCConfirmPregnantCell {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.bold(size: 21.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "SymptomChecker.Confirm.Pregnant".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makePregnantView() -> PregnantView {
        let view = PregnantView()
        view.noButton.addTarget(self, action: #selector(noTapped), for: .touchUpInside)
        view.yesButton.addTarget(self, action: #selector(yesTapped), for: .touchUpInside)
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 8.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
