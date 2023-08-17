//
//  SCPersonalViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SCPersonalViewController: UIViewController {
    lazy var mainView = SCPersonalView()
    
    private lazy var viewModel = SCPersonalViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var closeButton = UIButton()
    
    private lazy var ageAlertCreator = SelectAgeAlert()
    
    private lazy var didSelectAgeTrigger = PublishRelay<Int>()
    private lazy var didSelectGenderTrigger = PublishRelay<SelectGenderView.Gender>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AmplitudeManager.shared
            .logEvent(name: "Symptom Check Screen")
        
        let output = viewModel.configure(input: SCPersonalViewModel.Input(
            didSelectAge: didSelectAgeTrigger.asSignal(),
            didSelectGender: didSelectGenderTrigger.asSignal(),
            didTapContinue: mainView.continueButton.rx.tap.asSignal()
        ))
        
        output.age
            .drive(Binder(mainView) { base, age in
                base.setup(age: age)
            })
            .disposed(by: disposeBag)
        
        output.gender
            .drive(Binder(mainView.genderView) { base, gender in
                base.gender = gender
            })
            .disposed(by: disposeBag)
        
        output.enable
            .drive(Binder(mainView.continueButton) { base, enable in
                base.alpha = enable ? 1 : 0.3
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.navigationController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.disclaimerButton.rx.tap
            .bind(to: Binder(self) { base, void in
                let vc = DisclaimerViewController.make()
                base.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.ageButton.rx.tap
            .bind(to: Binder(self) { base, void in
                let alert = base.ageAlertCreator.alert { age in
                    base.didSelectAgeTrigger.accept(age)
                }
                base.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                mainView.genderView
                    .maleButton.rx.tap
                    .map { SelectGenderView.Gender.male },
                mainView.genderView
                    .femaleButton.rx.tap
                    .map { SelectGenderView.Gender.female }
            )
            .bind(to: didSelectGenderTrigger)
            .disposed(by: disposeBag)
        
        addCloseButton()
    }
}

// MARK: Make
extension SCPersonalViewController {
    static func make() -> SCPersonalViewController {
        let vc = SCPersonalViewController()
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "SymptomChecker.Title".localized
        return vc
    }
}

// MARK: Private
private extension SCPersonalViewController {
    func addCloseButton() {
        let item = UIBarButtonItem(customView: closeButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 14.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 14.scale).isActive = true
        
        closeButton.setImage(UIImage(named: "SymptomChecker.Close"), for: .normal)
        
        navigationItem.rightBarButtonItem = item
    }
    
    func route(_ route: SCPersonalViewModel.Route) {
        switch route {
        case .next(let collector):
            let vc = SCSymptomsViewController.make(collector: collector)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
