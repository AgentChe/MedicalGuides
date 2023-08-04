//
//  NoInteractionsFoundView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 04.08.2023.
//

import UIKit

final class NoInteractionsFoundView: UIView {
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var okButton = makeOkButton()
    lazy var disclaimerButton = makeDisclaimerButton()
    
    lazy var containerCenterYConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension NoInteractionsFoundView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        containerCenterYConstraint = container.centerYAnchor.constraint(equalTo: bottomAnchor, constant: 172.scale)
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 343.scale),
            container.heightAnchor.constraint(equalToConstant: 341.scale),
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerCenterYConstraint
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 81.scale),
            imageView.heightAnchor.constraint(equalToConstant: 76.scale),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.scale),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            okButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15.scale),
            okButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15.scale),
            okButton.heightAnchor.constraint(equalToConstant: 57.scale),
            okButton.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            disclaimerButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15.scale),
            disclaimerButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15.scale),
            disclaimerButton.heightAnchor.constraint(equalToConstant: 45.scale),
            disclaimerButton.topAnchor.constraint(equalTo: okButton.bottomAnchor, constant: 12.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension NoInteractionsFoundView {
    func makeDimmedView() -> UIView {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 20.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: "NoInteractionsFound.Image")
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.bold(size: 21.scale))
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "NoInteractionsFound.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black.withAlphaComponent(0.6))
            .font(Fonts.Avenir.bold(size: 15.scale))
            .lineHeight(19.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "NoInteractionsFound.SubTitle".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeOkButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.Avenir.medium(size: 15.scale))
        
        let view = UIButton()
        view.setAttributedTitle("OK".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeDisclaimerButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(UIColor(integralRed: 170, green: 170, blue: 170))
            .font(Fonts.Avenir.regular(size: 11.scale))
            .textAlignment(.center)
        
        let view = UIButton()
        view.titleLabel?.lineBreakMode = .byWordWrapping
        view.setAttributedTitle("NoInteractionsFound.Disclaimer".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
