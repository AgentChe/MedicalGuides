//
//  HomeViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 12.05.2023.
//

import UIKit
import RxSwift

final class HomeViewController: UIViewController {
    lazy var mainView = HomeView()
    
    private lazy var viewModel = HomeViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: .init(
            didTapSettings: mainView.settingsButton.rx.tap.asSignal(),
            didTapDrugGuide: mainView.tableView.didTapDrugGuide,
            didTapInteractionChecker: mainView.tableView.didTapInteractionChecker,
            didTapSymptomChecker: mainView.tableView.didTapSymptomChecker,
            didTapBookmark: mainView.tableView.didTapBookmark,
            didTapDisclaimer: mainView.disclaimerButton.rx.tap.asSignal())
        )
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: Make
extension HomeViewController {
    static func make() -> HomeViewController {
        let vc = HomeViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension HomeViewController {
    func route(_ route: HomeViewModel.Route) {
        switch route {
        case .settings:
            // TODO
            print("settings")
        case .drugGuide:
            // TODO
            print("drugGuide")
        case .interactionChecker:
            // TODO
            print("interactionChecker")
        case .symptomChecker:
            // TODO
            print("symptomChecker")
        case .bookmark:
            // TODO
            print("bookmark")
        case .disclaimer:
            let vc = DisclaimerViewController.make()
            present(vc, animated: true)
        }
    }
}
