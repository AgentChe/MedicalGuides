//
//  SettingsViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 19.05.2023.
//

import RxSwift
import RxCocoa

final class SettingsViewModel {
    enum Route {
        case disclaimer, contactUs, termsOfUse, privacyPolicy
    }
}

// MARK: Public
extension SettingsViewModel {
    struct Input {
        let didTapRouteElement: Signal<SettingsRoute>
    }
    
    struct Output {
        let sections: Driver<[SettingsTableSection]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        Output(
            sections: makeSections(),
            route: makeRoute(didTapRouteElement: input.didTapRouteElement)
        )
    }
}

// MARK: Private
private extension SettingsViewModel {
    func makeSections() -> Driver<[SettingsTableSection]> {
        Single<[SettingsTableSection]>
            .create { event in
                let sections: [SettingsTableSection] = [
                    .init(elements: [
                        .route(.disclaimer),
                        .route(.contactUs),
                        .route(.termsOfUse),
                        .route(.privacyPolicy)
                    ])
                ]
                event(.success(sections))
                
                return Disposables.create()
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeRoute(didTapRouteElement: Signal<SettingsRoute>) -> Driver<Route> {
        didTapRouteElement
            .map { route -> Route in
                switch route {
                case .disclaimer:
                    return .disclaimer
                case .contactUs:
                    return .contactUs
                case .termsOfUse:
                    return .termsOfUse
                case .privacyPolicy:
                    return .privacyPolicy
                }
            }
            .asDriver(onErrorDriveWith: .never())
    }
}
