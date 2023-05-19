//
//  SettingsTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingsTableView: UITableView {
    lazy var sections = [SettingsTableSection]()
    
    private lazy var didTapRouteTrigger = PublishRelay<SettingsRoute>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SettingsTableView {
    func setup(sections: [SettingsTableSection]) {
        self.sections = sections
        
        reloadData()
    }
    
    var didTapRoute: Signal<SettingsRoute> {
        didTapRouteTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SettingsTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section].elements[indexPath.row] {
        case .route(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SettingsRouteCell.self)) as! SettingsRouteCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension SettingsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section].elements[indexPath.row] {
        case .route(let element):
            didTapRouteTrigger.accept(element)
        }
    }
}

// MARK: Private
private extension SettingsTableView {
    func initialize() {
        register(SettingsRouteCell.self, forCellReuseIdentifier: String(describing: SettingsRouteCell.self))
        
        dataSource = self
        delegate = self
    }
}
