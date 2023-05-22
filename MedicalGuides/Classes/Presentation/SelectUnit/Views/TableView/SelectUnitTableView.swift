//
//  SelectUnitTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SelectUnitTableView: UITableView {
    lazy var elements = [SelectUnitTableElement]()
    
    private lazy var didSelectTrigger = PublishRelay<SelectUnitTableElement>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SelectUnitTableView {
    func setup(elements: [SelectUnitTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<SelectUnitTableElement> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SelectUnitTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: SelectUnitTableCell.self)) as! SelectUnitTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension SelectUnitTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        didSelectTrigger.accept(element)
    }
}

// MARK: Private
private extension SelectUnitTableView {
    func initialize() {
        register(SelectUnitTableCell.self, forCellReuseIdentifier: String(describing: SelectUnitTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
