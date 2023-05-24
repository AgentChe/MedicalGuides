//
//  SCResultViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import UIKit
import RxSwift

final class SCResultViewController: UIViewController {
    lazy var mainView = SCResultView()
    
    private lazy var viewModel = SCResultViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: SCResultViewModel.Input(
            
        ))
    }
}

// MARK: Make
extension SCResultViewController {
    static func make(collector: SymptomCheckerCollector) -> SCResultViewController {
        let vc = SCResultViewController()
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "SymptomChecker.Title".localized
        return vc
    }
}
