//
//  SCSymptomsViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SCSymptomsViewController: UIViewController {
    lazy var mainView = SCSymptomsView()
    
    private let viewModel: SCSymptomsViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var closeButton = UIButton()
    
    private lazy var didSelectSymptomTrigger = PublishRelay<Symptom>()
    
    private init(collector: SymptomCheckerCollector) {
        viewModel = SCSymptomsViewModel(collector: collector)
        
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
        
        let output = viewModel.configure(input: SCSymptomsViewModel.Input(
            didTapSelect: mainView.tableView.didTapSelect,
            didAddSymptom: didSelectSymptomTrigger.asSignal(),
            didRemoveSymptom: mainView.tableView.didRemoveSymptom,
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
extension SCSymptomsViewController {
    static func make(collector: SymptomCheckerCollector) -> SCSymptomsViewController {
        let vc = SCSymptomsViewController(collector: collector)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "SymptomChecker.Title".localized
        return vc
    }
}

// MARK: Private
private extension SCSymptomsViewController {
    func addCloseButton() {
        let item = UIBarButtonItem(customView: closeButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 14.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 14.scale).isActive = true
        
        closeButton.setImage(UIImage(named: "SymptomChecker.Close"), for: .normal)
        
        navigationItem.rightBarButtonItem = item
    }
    
    func route(_ route: SCSymptomsViewModel.Route) {
        switch route {
        case .selectSymptom(let selectedIds):
            let vc = SelectUnitViewController.make(unit: .symptoms, selectedIds: selectedIds) { [weak self] result in
                guard case let .symptom(symptom) = result else {
                    return
                }
                
                self?.didSelectSymptomTrigger.accept(symptom)
            }
            present(vc, animated: true)
        case .continue(let collector):
            let vc = SCConfirmViewController.make(collector: collector)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
