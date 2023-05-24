//
//  DrugsViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import RxSwift
import RxCocoa

final class DrugsViewModel {
    enum Route {
        case details(Drug)
    }
    
    private lazy var drugsManager = DrugsManager()
}

// MARK: Public
extension DrugsViewModel {
    struct Input {
        let didSearch: Signal<String>
        let didSelect: Signal<Drug>
    }
    
    struct Output {
        let elements: Driver<[Drug]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let drugs = makeDrugs()
        
        return Output(
            elements: makeElements(
                drugs: drugs,
                didSearch: input.didSearch
            ),
            route: makeRoute(didSelect: input.didSelect)
        )
    }
}

// MARK: Private
private extension DrugsViewModel {
    func makeElements(
        drugs: Driver<[Drug]>,
        didSearch: Signal<String>
    ) -> Driver<[Drug]> {
        Driver
            .combineLatest(
                drugs,
                didSearch.asDriver(onErrorDriveWith: .never())
            )
            .map { drugs, search -> [Drug] in
                guard !search.isEmpty else {
                    return drugs
                }
                
                return drugs.filter { drug -> Bool in
                    drug.name.contains(search)
                }
            }
    }
    
    func makeDrugs() -> Driver<[Drug]> {
        drugsManager
            .obtainDrugs(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(didSelect: Signal<Drug>) -> Driver<Route> {
        didSelect
            .asDriver(onErrorDriveWith: .never())
            .map { Route.details($0) }
    }
}
