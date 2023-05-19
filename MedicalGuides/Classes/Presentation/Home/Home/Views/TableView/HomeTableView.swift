//
//  HomeTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 12.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeTableView: UITableView {
    lazy var elements = [HomeTableElement]()
    
    private lazy var didTapDrugGuideTrigger = PublishRelay<Void>()
    private lazy var didTapInteractionCheckerTrigger = PublishRelay<Void>()
    private lazy var didTapSymptomCheckerTrigger = PublishRelay<Void>()
    private lazy var didTapBookmarkTrigger = PublishRelay<Void>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeTableView {
    func setup(elements: [HomeTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapDrugGuide: Signal<Void> {
        didTapDrugGuideTrigger.asSignal()
    }
    
    var didTapInteractionChecker: Signal<Void> {
        didTapInteractionCheckerTrigger.asSignal()
    }
    
    var didTapSymptomChecker: Signal<Void> {
        didTapSymptomCheckerTrigger.asSignal()
    }
    
    var didTapBookmark: Signal<Void> {
        didTapBookmarkTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension HomeTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: HomeTableCell.self)) as! HomeTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension HomeTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row].block {
        case .drugGuide:
            didTapDrugGuideTrigger.accept(Void())
        case .interactionChecker:
            didTapInteractionCheckerTrigger.accept(Void())
        case .symptomChecker:
            didTapSymptomCheckerTrigger.accept(Void())
        case .bookmark:
            didTapBookmarkTrigger.accept(Void())
        }
    }
}

// MARK: Private
private extension HomeTableView {
    func initialize() {
        register(HomeTableCell.self, forCellReuseIdentifier: String(describing: HomeTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
