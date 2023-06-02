//
//  SICDetailsTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 01.06.2023.
//

import UIKit

final class SICDetailsTableView: UITableView {
    lazy var sections = [SICDetailsTableSection]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SICDetailsTableView {
    func setup(sections: [SICDetailsTableSection]) {
        self.sections = sections
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension SICDetailsTableView: UITableViewDataSource {
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
        case .section(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SICDetailsSectionCell.self)) as! SICDetailsSectionCell
            cell.setup(element: element)
            return cell
        case .text(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SICDetailsTextCell.self)) as! SICDetailsTextCell
            cell.setup(element: element)
            return cell
        case .separator:
            return dequeueReusableCell(withIdentifier: String(describing: SICDetailsSeparatorCell.self), for: indexPath)
        }
    }
}

// MARK: UITableViewDelegate
extension SICDetailsTableView: UITableViewDelegate {
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
private extension SICDetailsTableView {
    func initialize() {
        register(SICDetailsSectionCell.self, forCellReuseIdentifier: String(describing: SICDetailsSectionCell.self))
        register(SICDetailsSeparatorCell.self, forCellReuseIdentifier: String(describing: SICDetailsSeparatorCell.self))
        register(SICDetailsTextCell.self, forCellReuseIdentifier: String(describing: SICDetailsTextCell.self))
        
        dataSource = self
        delegate = self
    }
}
