//
//  SettingsView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.05.2023.
//

import UIKit

final class SettingsView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var closeButton = makeCloseButton()
    lazy var tableView = makeTableView()
    
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
private extension SettingsView {
    func initialize() {
        backgroundColor = Appearance.secondary4
    }
}

// MARK: Make constraints
private extension SettingsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 64.scale : 30.scale)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 17.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 19.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 60.5.scale : 36.5.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SettingsView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.black(size: 33.scale))
            .lineHeight(45.08.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Settings.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Settings.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> SettingsTableView {
        let view = SettingsTableView(frame: .zero, style: .insetGrouped)
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20.scale, right: 0)
        view.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        view.separatorStyle = .singleLine
        view.separatorColor = Appearance.black.withAlphaComponent(0.1)
        view.separatorInset = UIEdgeInsets.zero
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
