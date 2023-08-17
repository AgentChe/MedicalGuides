//
//  OSymptomCheckerView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 11.05.2023.
//

import UIKit

final class OSymptomCheckerView: OSlideView {
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var textLabel = makeTextLabel()
    lazy var continueButton = makeContinueButton()
    lazy var disclaimerButton = makeDisclaimerButton()
    
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func moveToThis() {
        super.moveToThis()
        
        AmplitudeManager.shared
            .logEvent(name: "Onboarding Screen", parameters: ["step": 3])
    }
}

// MARK: Private
private extension OSymptomCheckerView {
    func initialize() {
        backgroundColor = Appearance.secondary4
    }
}

// MARK: Make constraints
private extension OSymptomCheckerView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 44.scale),
            imageView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 439.scale : 310.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 45.scale)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 57.scale),
            continueButton.bottomAnchor.constraint(equalTo: disclaimerButton.topAnchor, constant: -15.scale)
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
private extension OSymptomCheckerView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Onboarding.SymptomChecker")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.black(size: 30.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Onboarding.SymptomChecker.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTextLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.regular(size: 15.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Onboarding.SymptomChecker.Text".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.Avenir.regular(size: 15.scale))
            .textAlignment(.center)
        
        let view = UIButton()
        view.backgroundColor = Appearance.primary
        view.layer.cornerRadius = 10.scale
        view.setAttributedTitle("Continue".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        addSubview(view)
        return view
    }
    
    func makeDisclaimerButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.custom170)
            .font(Fonts.Avenir.regular(size: 13.scale))
            .lineHeight(18.2.scale)
            .textAlignment(.center)
        
        let view = UIButton()
        view.titleLabel?.lineBreakMode = .byWordWrapping
        view.setAttributedTitle("Onboarding.Disclaimer.Placeholder".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapDisclaimer), for: .touchUpInside)
        addSubview(view)
        return view
    }
}
