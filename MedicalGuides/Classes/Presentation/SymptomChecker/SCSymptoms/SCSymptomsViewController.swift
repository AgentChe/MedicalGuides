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
    
    private lazy var viewModel = SCSymptomsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var closeButton = UIButton()
    
    private lazy var didSelectSymptomTrigger = PublishRelay<Symptom>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: SCSymptomsViewModel.Input(
            didTapSelect: mainView.tableView.didTapSelect,
            didAddSymptom: didSelectSymptomTrigger.asSignal(),
            didRemoveSymptom: mainView.tableView.didRemoveSymptom
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
        
        addCloseButton()
    }
}

// MARK: Make
extension SCSymptomsViewController {
    static func make(collector: SymptomCheckerCollector) -> SCSymptomsViewController {
        let vc = SCSymptomsViewController()
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
        }
    }
}
