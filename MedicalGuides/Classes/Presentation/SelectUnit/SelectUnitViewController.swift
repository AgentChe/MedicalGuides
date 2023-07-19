//
//  SelectUnitViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

import UIKit
import RxSwift

final class SelectUnitViewController: UIViewController {
    lazy var mainView = SelectUnitView()
    
    private let viewModel: SelectUnitViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private let unit: SelectUnitViewModel.Unit
    private let didSelect: ((SelectUnitViewModel.Result) -> Void)
    
    private init(unit: SelectUnitViewModel.Unit, selectedIds: [Int], didSelect: @escaping ((SelectUnitViewModel.Result) -> Void)) {
        self.viewModel = SelectUnitViewModel(unit: unit, selectedIds: selectedIds)
        self.unit = unit
        self.didSelect = didSelect
        
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
        
        let output = viewModel.configure(input: SelectUnitViewModel.Input(
            didSearch: mainView.searchView.changedText,
            didSelect: mainView.tableView.didSelect
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.isEmpty
            .drive(Binder(self) { base, empty in
                base.empty(empty)
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
        
        mainView.rx.keyboardHeight
            .bind(to: Binder(mainView.tableView) { base, keyboardHeight in
                base.contentInset.bottom = keyboardHeight > 0 ? keyboardHeight + 20.scale : 20.scale
            })
            .disposed(by: disposeBag)
        
        setupTitle()
        mainView.searchView.textField.becomeFirstResponder()
    }
}

// MARK: Make
extension SelectUnitViewController {
    static func make(unit: SelectUnitViewModel.Unit, selectedIds: [Int], didSelect: @escaping ((SelectUnitViewModel.Result) -> Void)) -> SelectUnitViewController {
        let vc = SelectUnitViewController(unit: unit, selectedIds: selectedIds, didSelect: didSelect)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension SelectUnitViewController {
    func setupTitle() {
        let title: String
        switch unit {
        case .drugs, .interactionCheckerMed, .symptomMeds:
            title = "SelectUnit.Title.Drugs".localized
        case .symptoms:
            title = "SelectUnit.Title.Symptoms".localized
        case .medicalStates:
            title = "SelectUnit.Title.MedicalStates".localized
        }
        mainView.setup(title: title)
    }
    
    func empty(_ empty: Bool) {
        mainView.tableView.isHidden = empty
        mainView.emptyView.isHidden = !empty
    }
    
    func route(_ route: SelectUnitViewModel.Route) {
        switch route {
        case .result(let result):
            dismiss(animated: true) { [weak self] in
                self?.didSelect(result)
            }
        }
    }
}
