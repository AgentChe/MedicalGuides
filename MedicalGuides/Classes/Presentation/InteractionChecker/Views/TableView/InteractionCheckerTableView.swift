//
//  InteractionCheckerTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class InteractionCheckerTableView: UITableView {
    lazy var elements = [InteractionCheckerTableElement]()
    
    private lazy var didTapElementTrigger = PublishRelay<InteractionCheckerDrugElement>()
    private lazy var didTapDeleteTrigger = PublishRelay<InteractionCheckerDrugElement>()
    private lazy var didTapAddMoreTrigger = PublishRelay<Void>()
    private lazy var didTapCheckTrigger = PublishRelay<Void>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension InteractionCheckerTableView {
    func setup(elements: [InteractionCheckerTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapElement: Signal<InteractionCheckerDrugElement> {
        didTapElementTrigger.asSignal()
    }
    
    var didTapDelete: Signal<InteractionCheckerDrugElement> {
        didTapDeleteTrigger.asSignal()
    }
    
    var didTapAddMore: Signal<Void> {
        didTapAddMoreTrigger.asSignal()
    }
    
    var didTapCheck: Signal<Void> {
        didTapCheckTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension InteractionCheckerTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .drug(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: InteractionCheckerDrugCell.self)) as! InteractionCheckerDrugCell
            cell.setup(element: element)
            cell.didTapDelete = { [weak self] in
                self?.didTapDeleteTrigger.accept(element)
            }
            return cell
        case .addMore:
            return dequeueReusableCell(withIdentifier: String(describing: InteractionCheckerAddCell.self), for: indexPath)
        case .check:
            return dequeueReusableCell(withIdentifier: String(describing: InteractionCheckerCheckCell.self), for: indexPath)
        }
    }
}

// MARK: UITableViewDelegate
extension InteractionCheckerTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .drug(let element):
            didTapElementTrigger.accept(element)
        case .addMore:
            didTapAddMoreTrigger.accept(Void())
        case .check:
            didTapCheckTrigger.accept(Void())
        }
    }
}

// MARK: Private
private extension InteractionCheckerTableView {
    func initialize() {
        register(InteractionCheckerDrugCell.self, forCellReuseIdentifier: String(describing: InteractionCheckerDrugCell.self))
        register(InteractionCheckerAddCell.self, forCellReuseIdentifier: String(describing: InteractionCheckerAddCell.self))
        register(InteractionCheckerCheckCell.self, forCellReuseIdentifier: String(describing: InteractionCheckerCheckCell.self))
        
        dataSource = self
        delegate = self
    }
}
