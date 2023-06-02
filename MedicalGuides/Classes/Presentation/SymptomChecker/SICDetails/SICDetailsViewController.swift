//
//  SICDetailsViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 31.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SICDetailsViewController: UIViewController {
    lazy var mainView = SICDetailsView()
    
    private let viewModel: SICDetailsViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didTapMarkedTrigger = PublishRelay<Bool>()
    
    private lazy var markedButton = UIButton()
    
    private init(id: Int) {
        self.viewModel = SICDetailsViewModel(id: id)
        
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
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.open(error: error)
        }
        
        let didTapFilter = Observable
            .merge(
                mainView.filterView
                    .conditionDetailsButton.rx.tap
                    .map { SICDetailsFilterView.Filter.conditionDetails },
                mainView.filterView
                    .treatmentOptionsButton.rx.tap
                    .map { SICDetailsFilterView.Filter.treatmentOptions }
            )
            .asSignal(onErrorSignalWith: .never())
            .startWith(.conditionDetails)
        
        didTapFilter
            .emit(to: Binder(mainView.filterView) { base, filter in
                base.filter = filter
            })
            .disposed(by: disposeBag)
        
        let output = viewModel.configure(input: SICDetailsViewModel.Input(
            didTapMark: didTapMarkedTrigger.asSignal(),
            didTapFilter: didTapFilter
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
        
        output.name
            .drive(Binder(mainView) { base, name in
                base.setup(title: name)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView) { base, activity in
                base.filterView.isHidden = activity
                activity ? base.preloader.startAnimating() : base.preloader.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        mainView.disclaimerButton.rx.tap
            .bind(to: Binder(self) { base, void in
                let vc = DisclaimerViewController.make()
                base.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        addMarkedButton()
    }
}

// MARK: Public
extension SICDetailsViewController {
    static func make(id: Int) -> SICDetailsViewController {
        let vc = SICDetailsViewController(id: id)
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension SICDetailsViewController {
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
        let image = UIImage(named: marked ? "SIC.Saved" : "SIC.Unsaved")
        markedButton.setImage(image, for: .normal)
    }
}
