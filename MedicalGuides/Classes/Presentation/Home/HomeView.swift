//
//  HomeView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 12.05.2023.
//

import UIKit

final class HomeView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var settingsButton = makeSettingsButton()
    lazy var tableView = makeTableView()
    lazy var disclaimerButton = makeDisclaimerButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension HomeView {
    func initialize() {
        backgroundColor = Appearance.secondary4
    }
}

// MARK: Make constraints
private extension HomeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 64.scale : 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            settingsButton.widthAnchor.constraint(equalToConstant: 20.scale),
            settingsButton.heightAnchor.constraint(equalToConstant: 20.scale),
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            settingsButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: disclaimerButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            disclaimerButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            disclaimerButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -30.scale : -16.scale),
            disclaimerButton.heightAnchor.constraint(equalToConstant: 20.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.black(size: 33.scale))
            .lineHeight(45.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Home.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSettingsButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Home.Settings"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> HomeTableView {
        let view = HomeTableView()
        view.contentInset = UIEdgeInsets(top: 5.scale, left: 0, bottom: 30.scale, right: 0)
        view.setContentOffset(CGPoint(x: 0, y: -5.scale), animated: false)
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDisclaimerButton() -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(Appearance.black.withAlphaComponent(0.4))
            .font(Fonts.Avenir.regular(size: 13.scale))
            .textAlignment(.center)
        
        let view = TapAreaButton()
        view.setAttributedTitle("Home.Disclaimer".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
