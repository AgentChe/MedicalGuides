//
//  DrugsViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import UIKit
import RxSwift

final class DrugsViewController: UIViewController {
    lazy var mainView = DrugsView()
    
    private lazy var viewModel = DrugsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeManager.shared
            .logEvent(name: "Drug Guide Screen")
        
        let output = viewModel.configure(input: DrugsViewModel.Input(
            didSearch: mainView.searchView.changedText,
            didSelect: mainView.tableView.didSelect
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        mainView.rx.keyboardHeight
            .bind(to: Binder(mainView.tableView) { base, keyboardHeight in
                let bottom = keyboardHeight > 0 ? keyboardHeight + 20.scale : 20.scale
                base.contentInset.bottom = bottom
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension DrugsViewController {
    static func make() -> DrugsViewController {
        let vc = DrugsViewController()
        vc.navigationItem.title = "Drugs.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
    
    func route(_ route: DrugsViewModel.Route) {
        switch route {
        case .details(let drug):
            let vc = DrugViewController.make(drug: drug)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
