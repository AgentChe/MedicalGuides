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
    private lazy var didTapCheckTrigger = PublishRelay<Void>()
    private lazy var didTapBookmarkTrigger = PublishRelay<Bool>()
    
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
    
    var didTapCheck: Signal<Void> {
        didTapCheckTrigger.asSignal()
    }
    
    var didTapBookmark: Signal<Bool> {
        didTapBookmarkTrigger.asSignal()
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
            return cell
        case .check:
            return dequeueReusableCell(withIdentifier: String(describing: InteractionCheckerCheckCell.self), for: indexPath)
        case .preloader:
            let cell = dequeueReusableCell(withIdentifier: String(describing: InteractionCheckerPreloaderCell.self), for: indexPath) as! InteractionCheckerPreloaderCell
            cell.spinner.startAnimating()
            return cell
        case .result(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: InteractionCheckerResultCell.self), for: indexPath) as! InteractionCheckerResultCell
            cell.setup(element: element)
            cell.didTapBookmark = { [weak self] in
                self?.didTapBookmarkTrigger.accept(element.marked)
            }
            return cell
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
        case .check:
            didTapCheckTrigger.accept(Void())
        default:
            return
        }
    }
}

// MARK: Private
private extension InteractionCheckerTableView {
    func initialize() {
        register(InteractionCheckerDrugCell.self, forCellReuseIdentifier: String(describing: InteractionCheckerDrugCell.self))
        register(InteractionCheckerCheckCell.self, forCellReuseIdentifier: String(describing: InteractionCheckerCheckCell.self))
        register(InteractionCheckerPreloaderCell.self, forCellReuseIdentifier: String(describing: InteractionCheckerPreloaderCell.self))
        register(InteractionCheckerResultCell.self, forCellReuseIdentifier: String(describing: InteractionCheckerResultCell.self))
        
        dataSource = self
        delegate = self
    }
}
