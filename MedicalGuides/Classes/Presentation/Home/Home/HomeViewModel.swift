//
//  HomeViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 12.05.2023.
//

import RxSwift
import RxCocoa

final class HomeViewModel {
    enum Route {
        case settings
        case drugGuide
        case interactionChecker
        case symptomChecker
        case bookmark
        case disclaimer
    }
}

// MARK: Public
extension HomeViewModel {
    struct Input {
        let didTapSettings: Signal<Void>
        let didTapDrugGuide: Signal<Void>
        let didTapInteractionChecker: Signal<Void>
        let didTapSymptomChecker: Signal<Void>
        let didTapBookmark: Signal<Void>
        let didTapDisclaimer: Signal<Void>
    }
    
    struct Output {
        let elements: Driver<[HomeTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        Output(
            elements: makeElements(),
            route: makeRoute(input: input)
        )
    }
}

// MARK: Private
private extension HomeViewModel {
    func makeElements() -> Driver<[HomeTableElement]> {
        .deferred {
            .just([
                HomeTableElement(block: .drugGuide),
                HomeTableElement(block: .interactionChecker),
                HomeTableElement(block: .symptomChecker),
                HomeTableElement(block: .bookmark)
            ])
        }
    }
    
    func makeRoute(input: Input) -> Driver<Route> {
        Signal
            .merge(
                input.didTapSettings.map { Route.settings },
                input.didTapDrugGuide.map { Route.drugGuide },
                input.didTapInteractionChecker.map { Route.interactionChecker },
                input.didTapSymptomChecker.map { Route.symptomChecker },
                input.didTapBookmark.map { Route.bookmark },
                input.didTapDisclaimer.map { Route.disclaimer }
            )
            .asDriver(onErrorDriveWith: .never())
    }
}
