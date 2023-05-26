//
//  SCSymptomsView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import UIKit

final class SCSymptomsView: UIView {
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
private extension SCSymptomsView {
    func initialize() {
        backgroundColor = Appearance.secondary4
    }
}

// MARK: Make constraints
private extension SCSymptomsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SCSymptomsView {
    func makeTableView() -> SCSymptomsTableView {
        let view = SCSymptomsTableView()
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20.scale, right: 0)
        view.setContentOffset(CGPoint.zero, animated: false)
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
