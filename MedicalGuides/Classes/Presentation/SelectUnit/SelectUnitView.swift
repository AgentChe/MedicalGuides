//
//  SelectUnitView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

import UIKit

final class SelectUnitView: UIView {
    lazy var titleLabel = makeLabel()
    lazy var closeButton = makeCloseButton()
    lazy var searchView = makeSearchView()
    lazy var tableView = makeTableView()
    lazy var emptyView = makeEmptyView()
    
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
extension SelectUnitView {
    func setup(title: String) {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.regular(size: 15.scale))
            .lineHeight(22.scale)
            .letterSpacing(-0.41.scale)
            .textAlignment(.center)
        titleLabel.attributedText = title.attributed(with: attrs)
    }
}

// MARK: Private
private extension SelectUnitView {
    func initialize() {
        backgroundColor = Appearance.secondary4
    }
}

// MARK: Make constraints
private extension SelectUnitView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 54.scale : 34.scale)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 17.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 19.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            searchView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            searchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            searchView.heightAnchor.constraint(equalToConstant: 57.scale),
            searchView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 26.scale : 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 103.scale : 40.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SelectUnitView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "SelectUnit.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSearchView() -> SearchView {
        let view = SearchView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 10.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> SelectUnitTableView {
        let view = SelectUnitTableView()
        view.contentInset = UIEdgeInsets(top: 11.scale, left: 0, bottom: 20.scale, right: 0)
        view.setContentOffset(CGPoint(x: 0, y: -11.scale), animated: false)
        view.separatorStyle = .singleLine
        view.separatorColor = Appearance.primary.withAlphaComponent(0.1)
        view.separatorInset = UIEdgeInsets(top: 0, left: 16.scale, bottom: 0, right: 0)
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEmptyView() -> SelectUnitEmptyView {
        let view = SelectUnitEmptyView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
