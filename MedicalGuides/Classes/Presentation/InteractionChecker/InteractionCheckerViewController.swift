//
//  InteractionCheckerViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class InteractionCheckerViewController: UIViewController {
    lazy var mainView = InteractionCheckerView()
    
    private lazy var viewModel = InteractionCheckerViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didSelectDrugTrigger = PublishRelay<(Drug, String)>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: InteractionCheckerViewModel.Input(
            didTapElement: mainView.tableView.didTapElement,
            didTapDelete: mainView.tableView.didTapDelete,
            didTapAddMore: mainView.tableView.didTapAddMore,
            didTapCheck: mainView.tableView.didTapCheck,
            didSelectDrug: didSelectDrugTrigger.asSignal()
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
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.disclaimerButton.rx.tap
            .bind(to: Binder(self) { base, void in
                let vc = DisclaimerViewController.make()
                base.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension InteractionCheckerViewController {
    static func make() -> InteractionCheckerViewController {
        let vc = InteractionCheckerViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension InteractionCheckerViewController {
    func route(_ route: InteractionCheckerViewModel.Route) {
        switch route {
        case .selectDrug(let forElementId, let selectedIds):
            let vc = SelectUnitViewController.make(unit: .drugs, selectedIds: selectedIds) { [weak self] result in
                guard case let .drug(drug) = result else {
                    return
                }
                
                self?.didSelectDrugTrigger.accept((drug, forElementId))
            }
            present(vc, animated: true)
        }
    }
}
