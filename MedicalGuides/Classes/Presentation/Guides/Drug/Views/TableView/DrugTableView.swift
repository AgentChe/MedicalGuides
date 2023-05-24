//
//  DrugTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import UIKit

final class DrugTableView: UITableView {
    lazy var sections = [DrugTableSection]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DrugTableView {
    func setup(sections: [DrugTableSection]) {
        self.sections = sections
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension DrugTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = sections[section]
        return s.opened ? s.openedElements.count : s.closedElements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let elements = section.opened ? section.openedElements : section.closedElements
        
        switch elements[indexPath.row] {
        case .name(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DrugTableNameCell.self)) as! DrugTableNameCell
            cell.setup(element: element)
            return cell
        case .section(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DrugTableSectionCell.self)) as! DrugTableSectionCell
            cell.setup(element: element)
            return cell
        case .title(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DrugTableTitleCell.self)) as! DrugTableTitleCell
            cell.setup(element: element)
            return cell
        case .text(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: DrugTableTextCell.self)) as! DrugTableTextCell
            cell.setup(element: element)
            return cell
        case .separator:
            return dequeueReusableCell(withIdentifier: String(describing: DrugTableSeparatorCell.self), for: indexPath)
        }
    }
}

// MARK: UITableViewDelegate
extension DrugTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let elements = section.opened ? section.openedElements : section.closedElements
        
        guard case let .section(element) = elements[indexPath.row] else {
            return
        }
        
        element.opened.toggle()
        section.opened.toggle()
        
        reloadSections([indexPath.section], with: .automatic)
    }
}

// MARK: Private
private extension DrugTableView {
    func initialize() {
        register(DrugTableNameCell.self, forCellReuseIdentifier: String(describing: DrugTableNameCell.self))
        register(DrugTableSectionCell.self, forCellReuseIdentifier: String(describing: DrugTableSectionCell.self))
        register(DrugTableTitleCell.self, forCellReuseIdentifier: String(describing: DrugTableTitleCell.self))
        register(DrugTableTextCell.self, forCellReuseIdentifier: String(describing: DrugTableTextCell.self))
        register(DrugTableSeparatorCell.self, forCellReuseIdentifier: String(describing: DrugTableSeparatorCell.self))
        
        dataSource = self
        delegate = self
    }
}
