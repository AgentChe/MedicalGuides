//
//  BookmarkViewController.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import UIKit
import RxSwift

final class BookmarkViewController: UIViewController {
    enum NavigationMode {
        case normal, editable
    }
    
    lazy var mainView = BookmarkView()
    
    private lazy var viewModel = BookmarkViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var editButton = UIButton()
    private lazy var doneButton = UIButton()
    private lazy var deleteButton = UIButton()
    private lazy var closeButton = UIButton()
    
    private lazy var editItem = UIBarButtonItem(customView: editButton)
    private lazy var doneItem = UIBarButtonItem(customView: doneButton)
    private lazy var deleteItem = UIBarButtonItem(customView: deleteButton)
    private lazy var closeItem = UIBarButtonItem(customView: closeButton)
    
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
                    .drugsButton.rx.tap
                    .map { BookmarkFilterView.Filter.drugs },
                mainView.filterView
                    .interactionsButton.rx.tap
                    .map { BookmarkFilterView.Filter.interactions },
                mainView.filterView
                    .conditionsButton.rx.tap
                    .map { BookmarkFilterView.Filter.conditions }
            )
            .startWith(.drugs)
        
        didTapFilter
            .bind(to: Binder(mainView.filterView) { base, filter in
                base.filter = filter
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
        
        let output = viewModel.configure(input: BookmarkViewModel.Input(
            didTapFilter: didTapFilter.asSignal(onErrorSignalWith: .never()).startWith(.drugs),
            didTapDone: doneButton.rx.tap.asSignal(),
            didTapEdit: editButton.rx.tap.asSignal(),
            didTapDelete: deleteButton.rx.tap.asSignal(),
            didTapDrug: mainView.tableView.didTapDrug,
            didTapInteraction: mainView.tableView.didTapInteraction,
            didTapCondition: mainView.tableView.didTapCondition
        ))
        
        output.navigationMode
            .drive(Binder(self) { base, mode in
                base.navigationMode(mode)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        prepareNavigationItems()
    }
}

// MARK: Public
extension BookmarkViewController {
    static func make() -> BookmarkViewController {
        let vc = BookmarkViewController()
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "Bookmark.Title".localized
        return vc
    }
}

// MARK: Private
private extension BookmarkViewController {
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
    
    func prepareNavigationItems() {
        [
            editItem,
            doneItem,
            deleteItem,
            closeItem
        ].forEach { $0.customView?.translatesAutoresizingMaskIntoConstraints = false }
        
        editItem.customView?.widthAnchor.constraint(equalToConstant: 15.scale).isActive = true
        editItem.customView?.heightAnchor.constraint(equalToConstant: 14.scale).isActive = true
        
        closeItem.customView?.widthAnchor.constraint(equalToConstant: 14.scale).isActive = true
        closeItem.customView?.heightAnchor.constraint(equalToConstant: 14.scale).isActive = true
        
        doneItem.customView?.widthAnchor.constraint(equalToConstant: 40.scale).isActive = true
        doneItem.customView?.heightAnchor.constraint(equalToConstant: 19.scale).isActive = true
        
        deleteItem.customView?.widthAnchor.constraint(equalToConstant: 16.scale).isActive = true
        deleteItem.customView?.heightAnchor.constraint(equalToConstant: 19.scale).isActive = true
        
        editButton.setImage(UIImage(named: "Bookmark.Edit"), for: .normal)
        closeButton.setImage(UIImage(named: "Bookmark.Close"), for: .normal)
        deleteButton.setImage(UIImage(named: "Bookmark.Delete"), for: .normal)
        let doneAttrs = TextAttributes()
            .textColor(Appearance.primary)
            .font(Fonts.Avenir.medium(size: 16.scale))
        doneButton.setAttributedTitle("Bookmark.Done".localized.attributed(with: doneAttrs), for: .normal)
    }
    
    func navigationMode(_ navigationMode: NavigationMode) {
        switch navigationMode {
        case .normal:
            navigationItem.rightBarButtonItem = closeItem
            navigationItem.leftBarButtonItem = editItem
        case .editable:
            navigationItem.rightBarButtonItem = deleteItem
            navigationItem.leftBarButtonItem = doneItem
        }
    }
}
