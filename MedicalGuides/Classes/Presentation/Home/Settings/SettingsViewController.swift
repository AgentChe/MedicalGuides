//
//  SettingsViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.05.2023.
//

import UIKit
import RxSwift

final class SettingsViewController: UIViewController {
    lazy var mainView = SettingsView()
    
    private lazy var viewModel = SettingsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: .init(
            didTapRouteElement: mainView.tableView.didTapRoute
        ))
        
        output.sections
            .drive(Binder(mainView.tableView) { base, sections in
                base.setup(sections: sections)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension SettingsViewController {
    static func make() -> SettingsViewController {
        let vc = SettingsViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension SettingsViewController {
    func route(_ route: SettingsViewModel.Route) {
        switch route {
        case .disclaimer:
            let vc = DisclaimerViewController.make()
            present(vc, animated: true)
        case .contactUs:
            open(path: GlobalDefinitions.contactUsUrl)
        case .termsOfUse:
            open(path: GlobalDefinitions.termsOfServiceUrl)
        case .privacyPolicy:
            open(path: GlobalDefinitions.privacyPolicyUrl)
        }
    }
    
    func open(path: String) {
        guard let url = URL(string: path) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
}
