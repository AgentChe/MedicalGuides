//
//  SICDetailsView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 31.05.2023.
//

import UIKit

final class SICDetailsView: UIView {
    lazy var titleLabel = makeLabel()
    lazy var filterView = makeFilterView()
    lazy var tableView = makeTableView()
    lazy var disclaimerButton = makeDisclaimerButton()
    lazy var preloader = makePreloader()
    
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
extension SICDetailsView {
    func setup(title: String) {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.black(size: 25.scale))
            .textAlignment(.left)
        titleLabel.attributedText = title.attributed(with: attrs)
    }
}

// MARK: Private
private extension SICDetailsView {
    func initialize() {
        backgroundColor = Appearance.secondary4
    }
}

// MARK: Make constraints
private extension SICDetailsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            filterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: trailingAnchor),
            filterView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.scale),
            filterView.heightAnchor.constraint(equalToConstant: 37.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: disclaimerButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            disclaimerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            disclaimerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            disclaimerButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -23.scale),
            disclaimerButton.heightAnchor.constraint(equalToConstant: 54.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SICDetailsView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeFilterView() -> SICDetailsFilterView {
        let view = SICDetailsFilterView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> SICDetailsTableView {
        let view = SICDetailsTableView()
        view.contentInset = UIEdgeInsets(top: 16.scale, left: 0, bottom: 20.scale, right: 0)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = UIColor.clear
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
        view.setAttributedTitle("SICDetails.Disclaimer".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 45.scale, height: 45.scale))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
