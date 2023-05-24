//
//  SCPersonalViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import RxSwift
import RxCocoa

final class SCPersonalViewModel {
    enum Route {
        case next(SymptomCheckerCollector)
    }
}

// MARK: Public
extension SCPersonalViewModel {
    struct Input {
        let didSelectAge: Signal<Int>
        let didSelectGender: Signal<SelectGenderView.Gender>
        let didTapContinue: Signal<Void>
    }
    
    struct Output {
        let age: Driver<Int>
        let gender: Driver<SelectGenderView.Gender>
        let enable: Driver<Bool>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        let age = makeAge(didSelectAge: input.didSelectAge)
        let gender = makeGender(didSelectGender: input.didSelectGender)
        let collector = makeCollector(
            age: age,
            gender: gender
        )
        
        return Output(
            age: age,
            gender: gender,
            enable: makeEnable(age: age),
            route: makeRoute(
                didTapContinue: input.didTapContinue,
                collector: collector
            )
        )
    }
}

// MARK: Private
private extension SCPersonalViewModel {
    func makeAge(didSelectAge: Signal<Int>) -> Driver<Int> {
        didSelectAge
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeGender(didSelectGender: Signal<SelectGenderView.Gender>) -> Driver<SelectGenderView.Gender> {
        didSelectGender
            .asDriver(onErrorDriveWith: .never())
            .startWith(.male)
    }
    
    func makeEnable(
        age: Driver<Int>
    ) -> Driver<Bool> {
        age
            .map { _ in true }
            .startWith(false)
    }
    
    func makeCollector(
        age: Driver<Int>,
        gender: Driver<SelectGenderView.Gender>
    ) -> Driver<SymptomCheckerCollector> {
        Driver
            .combineLatest(age, gender) {
                let collector = SymptomCheckerCollector()
                collector.age = $0
                collector.gender = $1.code
                return collector
            }
    }
    
    func makeRoute(
        didTapContinue: Signal<Void>,
        collector: Driver<SymptomCheckerCollector>
    ) -> Driver<Route> {
        didTapContinue
            .withLatestFrom(collector)
            .map { Route.next($0) }
            .asDriver(onErrorDriveWith: .never())
    }
}
