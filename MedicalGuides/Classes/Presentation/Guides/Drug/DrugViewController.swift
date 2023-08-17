//
//  DrugViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class DrugViewController: UIViewController {
    lazy var mainView = DrugView()
    
    private let viewModel: DrugViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var markedButton = UIButton()
    
    private lazy var didTapMarkedTrigger = PublishRelay<Bool>()
    
    private init(id: Int) {
        viewModel = DrugViewModel(id: id)
        
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
            .logEvent(name: "Drug Content Screen")
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.open(error: error)
        }
        
        let output = viewModel.configure(input: DrugViewModel.Input(
            didTapMark: didTapMarkedTrigger.asSignal()
        ))
        
        let marked = output.marked
        
        markedButton.rx.tap
            .withLatestFrom(marked)
            .bind(to: didTapMarkedTrigger)
            .disposed(by: disposeBag)
        
        marked
            .drive(Binder(self) { base, marked in
                base.update(marked: marked)
            })
            .disposed(by: disposeBag)
        
        output.sections
            .drive(Binder(mainView.tableView) { base, sections in
                base.setup(sections: sections)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.disposable
            .disposed(by: disposeBag)
        
        addMarkedButton()
    }
}

// MARK: Make
extension DrugViewController {
    static func make(drug: Drug) -> DrugViewController {
        let vc = DrugViewController(id: drug.id)
        vc.navigationItem.title = drug.name
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension DrugViewController {
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
    
    func addMarkedButton() {
        let item = UIBarButtonItem(customView: markedButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 12.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 18.scale).isActive = true
        
        navigationItem.rightBarButtonItem = item
    }
    
    func update(marked: Bool) {
        let image = UIImage(named: marked ? "Drug.Saved" : "Drug.Unsaved")
        markedButton.setImage(image, for: .normal)
    }
    
    func route(_ route: DrugViewModel.Route) {
        switch route {
        case .paygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}
