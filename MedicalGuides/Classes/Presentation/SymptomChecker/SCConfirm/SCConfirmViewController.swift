//
//  SCConfirmViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SCConfirmViewController: UIViewController {
    lazy var mainView = SCConfirmView()
    
    private let viewModel: SCConfirmViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var closeButton = UIButton()
    
    private lazy var didAddMedicationTrigger = PublishRelay<SymptomMed>()
    private lazy var didAddConditionTrigger = PublishRelay<MedicalState>()
    
    private init(collector: SymptomCheckerCollector) {
        viewModel = SCConfirmViewModel(collector: collector)
        
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
        
        let output = viewModel.configure(input: SCConfirmViewModel.Input(
            didSelectMostSymptom: mainView.tableView.didSelectMostSymptom,
            didSelectPregnant: mainView.tableView.didSelectPregnant,
            didTapChoose: mainView.tableView.didTapChoose,
            didAddMedication: didAddMedicationTrigger.asSignal(),
            didRemoveMedication: mainView.tableView.didRemoveMedication,
            didAddCondition: didAddConditionTrigger.asSignal(),
            didRemoveCondition: mainView.tableView.didRemoveCondition,
            didTapContinue: mainView.tableView.didTapContinue
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
        
        addCloseButton()
    }
}

// MARK: Make
extension SCConfirmViewController {
    static func make(collector: SymptomCheckerCollector) -> SCConfirmViewController {
        let vc = SCConfirmViewController(collector: collector)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "SymptomChecker.Title".localized
        return vc
    }
}

// MARK: Private
private extension SCConfirmViewController {
    func addCloseButton() {
        let item = UIBarButtonItem(customView: closeButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 14.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 14.scale).isActive = true
        
        closeButton.setImage(UIImage(named: "SymptomChecker.Close"), for: .normal)
        
        navigationItem.rightBarButtonItem = item
    }
    
    func route(_ route: SCConfirmViewModel.Route) {
        switch route {
        case .selectMedications(let selectedIds):
            let vc = SelectUnitViewController.make(unit: .symptomMeds, selectedIds: selectedIds) { [weak self] result in
                guard case let .symptomMed(med) = result else {
                    return
                }
                
                self?.didAddMedicationTrigger.accept(med)
            }
            present(vc, animated: true)
        case .selectConditions(let selectedIds):
            let vc = SelectUnitViewController.make(unit: .medicalStates, selectedIds: selectedIds) { [weak self] result in
                guard case let .medicalState(state) = result else {
                    return
                }
                
                self?.didAddConditionTrigger.accept(state)
            }
            present(vc, animated: true)
        case .continue(let collector):
            let vc = SCResultViewController.make(collector: collector)
            navigationController?.pushViewController(vc, animated: true)
        case .paygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}
