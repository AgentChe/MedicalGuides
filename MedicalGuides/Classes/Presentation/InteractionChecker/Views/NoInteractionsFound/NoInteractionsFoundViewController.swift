//
//  NoInteractionsFoundViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 04.08.2023.
//

import UIKit
import RxSwift

class NoInteractionsFoundViewController: UIViewController {
    lazy var mainView = NoInteractionsFoundView()

    private lazy var disposeBag = DisposeBag()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.disclaimerButton.rx.tap
            .subscribe(Binder(self) { base, void in
                let vc = DisclaimerViewController.make()
                base.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.okButton.rx.tap
            .subscribe(Binder(self) { base, void in
                base.dismiss()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateShow()
    }
}

// MARK: Make
extension NoInteractionsFoundViewController {
    static func make() -> NoInteractionsFoundViewController {
        let vc = NoInteractionsFoundViewController()
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension NoInteractionsFoundViewController {
    func animateShow() {
        mainView.containerCenterYConstraint.isActive = false
        mainView.containerCenterYConstraint = mainView.container.centerYAnchor.constraint(equalTo: mainView.centerYAnchor)
        mainView.containerCenterYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mainView.dimmedView.alpha = 0.6
            self?.mainView.layoutIfNeeded()
        })
    }

    func dismiss() {
        animateDismiss { [weak self] in
            self?.dismiss(animated: false)
        }
    }
    
    func animateDismiss(completion: @escaping (() -> Void)) {
        mainView.containerCenterYConstraint.isActive = false
        mainView.containerCenterYConstraint = mainView.container.centerYAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 172.scale)
        mainView.containerCenterYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mainView.dimmedView.alpha = 0
            self?.mainView.layoutIfNeeded()
        }, completion: { result in
            completion()
        })
    }
}
