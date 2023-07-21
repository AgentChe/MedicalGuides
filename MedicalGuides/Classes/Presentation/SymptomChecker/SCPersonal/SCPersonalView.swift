//
//  SCPersonalView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import UIKit

final class SCPersonalView: UIView {
    lazy var ageTitleLabel = makeTitleLabel("SymptomChecker.Personal.Age".localized)
    lazy var ageButton = makeAgeButton()
    lazy var sexTitleLabel = makeTitleLabel("SymptomChecker.Personal.Sex".localized)
    lazy var genderView = makeGenderView()
    lazy var continueButton = makeContinueButton()
    lazy var disclaimerButton = makeDisclaimerButton()
    
    private lazy var ageAttrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.black(size: 17.scale))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SCPersonalView {
    func setup(age: Int) {
        let string = "\(age)".attributed(with: ageAttrs)
        ageButton.setAttributedTitle(string, for: .normal)
    }
}

// MARK: Private
private extension SCPersonalView {
    func initialize() {
        backgroundColor = Appearance.secondary4
    }
}

// MARK: Make constraints
private extension SCPersonalView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            ageTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            ageTitleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 33.scale)
        ])
        
        NSLayoutConstraint.activate([
            ageButton.widthAnchor.constraint(equalToConstant: 55.scale),
            ageButton.heightAnchor.constraint(equalToConstant: 55.scale),
            ageButton.leadingAnchor.constraint(equalTo: ageTitleLabel.trailingAnchor, constant: 20.scale),
            ageButton.centerYAnchor.constraint(equalTo: ageTitleLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            sexTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            sexTitleLabel.topAnchor.constraint(equalTo: ageTitleLabel.bottomAnchor, constant: 41.scale)
        ])
        
        NSLayoutConstraint.activate([
            genderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            genderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            genderView.heightAnchor.constraint(equalToConstant: 45.scale),
            genderView.topAnchor.constraint(equalTo: sexTitleLabel.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 55.scale),
            continueButton.topAnchor.constraint(equalTo: genderView.bottomAnchor, constant: 74.scale)
        ])
        
        NSLayoutConstraint.activate([
            disclaimerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            disclaimerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            disclaimerButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -23.scale),
            disclaimerButton.heightAnchor.constraint(equalToConstant: 54.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SCPersonalView {
    func makeTitleLabel(_ title: String) -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.bold(size: 21.scale))
        
        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeAgeButton() -> TapAreaButton {
        let placeholderAttrs = TextAttributes()
            .textColor(Appearance.black.withAlphaComponent(0.3))
            .font(Fonts.Avenir.regular(size: 15.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle("21".attributed(with: placeholderAttrs), for: .normal)
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeGenderView() -> SelectGenderView {
        let view = SelectGenderView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.Avenir.regular(size: 15.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Continue".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDisclaimerButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.black.withAlphaComponent(0.4))
            .font(Fonts.Avenir.regular(size: 14.scale))
            .lineHeight(19.12.scale)
            .textAlignment(.center)
        
        let view = UIButton()
        view.titleLabel?.lineBreakMode = .byWordWrapping
        view.setAttributedTitle("SymptomChecker.Disclaimer".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
