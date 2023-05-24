//
//  SCConfirmViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import UIKit
import RxSwift

final class SCConfirmViewController: UIViewController {
    lazy var mainView = SCConfirmView()
    
    private lazy var viewModel = SCConfirmViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: SCConfirmViewModel.Input(
            
        ))
    }
}

// MARK: Make
extension SCConfirmViewController {
    static func make(collector: SymptomCheckerCollector) -> SCConfirmViewController {
        let vc = SCConfirmViewController()
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "SymptomChecker.Title".localized
        return vc
    }
}
