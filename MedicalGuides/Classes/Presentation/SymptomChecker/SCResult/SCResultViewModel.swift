//
//  SCResultViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import RxSwift
import RxCocoa

final class SCResultViewModel {
    enum Route {
        case details(SymptomsInteractionCondition)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var symptomsManager = SymptomsManager()
    
    private lazy var activity = RxActivityIndicator()
    
    private let collector: Driver<SymptomCheckerCollector>
    private lazy var conditions = makeConditions()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    init(collector: SymptomCheckerCollector) {
        self.collector = BehaviorRelay(value: collector).asDriver()
    }
}

// MARK: Public
extension SCResultViewModel {
    struct Input {
        let didTapCondition: Signal<SymptomsInteractionCondition>
    }
    
    struct Output {
        let elements: Driver<[SCResultTableElement]>
        let activity: Driver<Bool>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        Output(
            elements: makeElements(),
            activity: activity.asDriver(),
            route: makeRoute(didTapCondition: input.didTapCondition)
        )
    }
}

// MARK: Private
private extension SCResultViewModel {
    func makeElements() -> Driver<[SCResultTableElement]> {
        conditions
            .map { conditions -> [SCResultTableElement] in
                var result: [SCResultTableElement] = [.title("SymptomChecker.Result.Title".localized)]
                
                conditions.forEach { result.append(.condition($0)) }
                
                return result
            }
    }
    
    func makeConditions() -> Driver<[SymptomsInteractionCondition]> {
        collector
            .flatMapLatest { [weak self] collector -> Driver<[SymptomsInteractionCondition]> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<[SymptomsInteractionCondition]> {
                    guard
                        let age = collector.age,
                        let sex = collector.gender,
                        let symptoms = collector.symptoms,
                        let mainSymptomId = collector.mainSymptomId,
                        let pregnant = collector.pregnant,
                        let currentMedicationsIds = collector.currentMedicationsIds,
                        let medicalStatesIds = collector.medicalStatesIds
                    else {
                        return .error(ContentError(.notContent))
                    }
                    
                    return self.symptomsManager
                        .checkOnInteraction(
                            age: age,
                            sex: sex,
                            symptomsIds: symptoms.map { $0.id },
                            mainSymptomId: mainSymptomId,
                            pregnant: pregnant,
                            currentMedicationsIds: currentMedicationsIds,
                            medicalStatesIds: medicalStatesIds
                        )
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(self.activity)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeRoute(didTapCondition: Signal<SymptomsInteractionCondition>) -> Driver<Route> {
        didTapCondition
            .map { Route.details($0) }
            .asDriver(onErrorDriveWith: .never())
    }
}
