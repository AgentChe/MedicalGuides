//
//  SCResultTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 31.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SCResultTableView: UITableView {
    lazy var elements = [SCResultTableElement]()
    
    private lazy var didTapConditionTrigger = PublishRelay<SymptomsInteractionCondition>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SCResultTableView {
    func setup(elements: [SCResultTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapCondition: Signal<SymptomsInteractionCondition> {
        didTapConditionTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SCResultTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .title(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SCResultTitleCell.self), for: indexPath) as! SCResultTitleCell
            cell.setup(element: element)
            return cell
        case .condition(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SCResultConditionCell.self), for: indexPath) as! SCResultConditionCell
            cell.setup(element: element)
            cell.didTapReadMore = { [weak self] in
                self?.didTapConditionTrigger.accept(element)
            }
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension SCResultTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension SCResultTableView {
    func initialize() {
        register(SCResultTitleCell.self, forCellReuseIdentifier: String(describing: SCResultTitleCell.self))
        register(SCResultConditionCell.self, forCellReuseIdentifier: String(describing: SCResultConditionCell.self))
        
        dataSource = self
        delegate = self
    }
}
