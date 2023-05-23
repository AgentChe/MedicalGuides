//
//  DrugsTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class DrugsTableView: UITableView {
    lazy var elements = [Drug]()
    
    private lazy var didSelectTrigger = PublishRelay<Drug>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DrugsTableView {
    func setup(elements: [Drug]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<Drug> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension DrugsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: DrugsTableCell.self)) as! DrugsTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension DrugsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        didSelectTrigger.accept(element)
    }
}

// MARK: Private
private extension DrugsTableView {
    func initialize() {
        register(DrugsTableCell.self, forCellReuseIdentifier: String(describing: DrugsTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
