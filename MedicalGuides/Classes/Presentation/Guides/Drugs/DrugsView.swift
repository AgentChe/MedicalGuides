//
//  DrugsView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import UIKit

final class DrugsView: UIView {
    lazy var searchView = makeSearchView()
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
private extension DrugsView {
    func initialize() {
        backgroundColor = Appearance.secondary4
    }
}

// MARK: Make constraints
private extension DrugsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            searchView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            searchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            searchView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DrugsView {
    func makeSearchView() -> DrugsSearchView {
        let view = DrugsSearchView()
        view.layer.cornerRadius = 10.scale
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(integralRed: 118, green: 118, blue: 128, alpha: 0.12)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> DrugsTableView {
        let view = DrugsTableView()
        view.contentInset = UIEdgeInsets(top: 16.scale, left: 0, bottom: 20.scale, right: 0)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.separatorStyle = .singleLine
        view.separatorColor = UIColor(integralRed: 218, green: 220, blue: 227)
        view.separatorInset = UIEdgeInsets(top: 0, left: 20.scale, bottom: 0, right: 0)
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
