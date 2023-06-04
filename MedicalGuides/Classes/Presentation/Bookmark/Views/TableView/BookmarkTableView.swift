//
//  BookmarkTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class BookmarkTableView: UITableView {
    lazy var elements = [BookmarkTableElement]()
    
    private lazy var didTapDrugTrigger = PublishRelay<Drug>()
    private lazy var didTapInteractionTrigger = PublishRelay<DrugsInteraction>()
    private lazy var didTapConditionTrigger = PublishRelay<SymptomsInteractionConditionDetails>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension BookmarkTableView {
    func setup(elements: [BookmarkTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapDrug: Signal<Drug> {
        didTapDrugTrigger.asSignal()
    }
    
    var didTapInteraction: Signal<DrugsInteraction> {
        didTapInteractionTrigger.asSignal()
    }
    
    var didTapCondition: Signal<SymptomsInteractionConditionDetails> {
        didTapConditionTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension BookmarkTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = elements[indexPath.row]
        switch element.unit {
        case .drug(let drug):
            let cell = dequeueReusableCell(withIdentifier: String(describing: BookmarkDrugCell.self), for: indexPath) as! BookmarkDrugCell
            cell.setup(
                drug: drug,
                selected: element.seleted,
                separatorHidden: (elements.count - 1) == indexPath.row
            )
            return cell
        case .interaction(let interaction):
            let cell = dequeueReusableCell(withIdentifier: String(describing: BookmarkInteractionCell.self), for: indexPath) as! BookmarkInteractionCell
            cell.setup(interaction: interaction, selected: element.seleted)
            return cell
        case .condition(let condition):
            let cell = dequeueReusableCell(withIdentifier: String(describing: BookmarkConditionCell.self), for: indexPath) as! BookmarkConditionCell
            cell.setup(condition: condition, selected: element.seleted)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension BookmarkTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        switch element.unit {
        case .drug(let drug):
            didTapDrugTrigger.accept(drug)
        case .interaction(let interaction):
            didTapInteractionTrigger.accept(interaction.interaction)
        case .condition(let condition):
            didTapConditionTrigger.accept(condition)
        }
    }
}

// MARK: Private
private extension BookmarkTableView {
    func initialize() {
        register(BookmarkDrugCell.self, forCellReuseIdentifier: String(describing: BookmarkDrugCell.self))
        register(BookmarkInteractionCell.self, forCellReuseIdentifier: String(describing: BookmarkInteractionCell.self))
        register(BookmarkConditionCell.self, forCellReuseIdentifier: String(describing: BookmarkConditionCell.self))
        
        dataSource = self
        delegate = self
    }
}
