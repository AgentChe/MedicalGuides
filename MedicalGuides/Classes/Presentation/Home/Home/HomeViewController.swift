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
    
    private let requestReview: Bool
    
    private init(requestReview: Bool) {
        self.requestReview = requestReview

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeManager.shared
            .logEvent(name: "Main Screen")
        
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
        
        if requestReview {
            RequestReview.request()
        }
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
    static func make(requestReview: Bool) -> HomeViewController {
        let vc = HomeViewController(requestReview: requestReview)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension HomeViewController {
    func route(_ route: HomeViewModel.Route) {
        switch route {
        case .settings:
            let vc = SettingsViewController.make()
            present(vc, animated: true)
        case .drugGuide:
            let vc = DrugsViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        case .interactionChecker:
            let vc = InteractionCheckerViewController.make()
            present(vc, animated: true)
        case .symptomChecker:
            let vc = NavigationController(rootViewController: SCPersonalViewController.make())
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        case .bookmark:
            let vc = NavigationController(rootViewController: BookmarkViewController.make())
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        case .disclaimer:
            let vc = DisclaimerViewController.make()
            present(vc, animated: true)
        }
    }
}
