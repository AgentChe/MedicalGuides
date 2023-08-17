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
    
    private let viewModel: InteractionCheckerViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didSelectDrugTrigger = PublishRelay<(InteractionCheckerMed, String)>()
    
    private init(drugsInteraction: DrugsInteraction?) {
        viewModel = InteractionCheckerViewModel(drugsInteraction: drugsInteraction)
        
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
        
        AmplitudeManager.shared
            .logEvent(name: "Interaction Check Screen")
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.open(error: error)
        }
        
        let output = viewModel.configure(input: InteractionCheckerViewModel.Input(
            didTapElement: mainView.tableView.didTapElement,
            didTapCheck: mainView.tableView.didTapCheck,
            didSelectDrug: didSelectDrugTrigger.asSignal(),
            didTapBookmark: mainView.tableView.didTapBookmark
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
    static func make(drugsInteraction: DrugsInteraction? = nil) -> InteractionCheckerViewController {
        let vc = InteractionCheckerViewController(drugsInteraction: drugsInteraction)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension InteractionCheckerViewController {
    func route(_ route: InteractionCheckerViewModel.Route) {
        switch route {
        case .selectDrug(let forElementId, let selectedIds):
            let vc = SelectUnitViewController.make(unit: .interactionCheckerMed, selectedIds: selectedIds) { [weak self] result in
                guard case let .interactionCheckerMed(med) = result else {
                    return
                }
                
                self?.didSelectDrugTrigger.accept((med, forElementId))
            }
            present(vc, animated: true)
        case .paygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        case .noInteractionsFound:
            let vc = NoInteractionsFoundViewController.make()
            present(vc, animated: false)
        }
    }
    
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make(error: error) {
                    observe.onNext(())
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
}
