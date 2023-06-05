//
//  SettingsRouteCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.05.2023.
//

import UIKit

final class SettingsRouteCell: UITableViewCell {
    lazy var label = makeLabel()
    lazy var arrowView = makeArrowView()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.medium(size: 15.scale))
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
extension SettingsRouteCell {
    func setup(element: SettingsRoute) {
        label.attributedText = title(for: element).attributed(with: attrs)
    }
}

// MARK: Private
private extension SettingsRouteCell {
    func initialize() {
        backgroundColor = Appearance.white
        contentView.backgroundColor = Appearance.white
        
        selectionStyle = .none
    }
    
    func title(for route: SettingsRoute) -> String {
        switch route {
        case .disclaimer:
            return "Settings.Disclaimer".localized
        case .contactUs:
            return "Settings.ContactUs".localized
        case .termsOfUse:
            return "Settings.TermsOfUse".localized
        case .privacyPolicy:
            return "Settings.PrivacyPolicy".localized
        }
    }
}

// MARK: Make constraints
private extension SettingsRouteCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18.scale)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 13.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 19.scale),
            arrowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale),
            arrowView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SettingsRouteCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Settings.Arrow")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
