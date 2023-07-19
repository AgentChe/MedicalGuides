//
//  SCConfirmTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 26.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SCConfirmTableView: UITableView {
    lazy var elements = [SCConfirmTableElement]()
    
    private lazy var didSelectMostSymptomTrigger = PublishRelay<Symptom>()
    private lazy var didSelectPregnantTrigger = PublishRelay<Bool>()
    private lazy var didTapChooseTrigger = PublishRelay<SCConfirmChooseElement>()
    private lazy var didRemoveMedicationTrigger = PublishRelay<SymptomMed>()
    private lazy var didRemoveConditionTrigger = PublishRelay<MedicalState>()
    private lazy var didTapContinueTrigger = PublishRelay<Void>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SCConfirmTableView {
    func setup(elements: [SCConfirmTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelectMostSymptom: Signal<Symptom> {
        didSelectMostSymptomTrigger.asSignal()
    }
    
    var didSelectPregnant: Signal<Bool> {
        didSelectPregnantTrigger.asSignal()
    }
    
    var didTapChoose: Signal<SCConfirmChooseElement> {
        didTapChooseTrigger.asSignal()
    }
    
    var didRemoveMedication: Signal<SymptomMed> {
        didRemoveMedicationTrigger.asSignal()
    }
    
    var didRemoveCondition: Signal<MedicalState> {
        didRemoveConditionTrigger.asSignal()
    }
    
    var didTapContinue: Signal<Void> {
        didTapContinueTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SCConfirmTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .mostSymptom(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SCConfirmMostSymptomCell.self), for: indexPath) as! SCConfirmMostSymptomCell
            cell.setup(element: element)
            cell.didSelect = { [weak self] symptom in
                self?.didSelectMostSymptomTrigger.accept(symptom)
            }
            return cell
        case .pregnant:
            let cell = dequeueReusableCell(withIdentifier: String(describing: SCConfirmPregnantCell.self), for: indexPath) as! SCConfirmPregnantCell
            cell.didSelect = { [weak self] pregnant in
                self?.didSelectPregnantTrigger.accept(pregnant)
            }
            return cell
        case .choose(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SCConfirmChooseCell.self), for: indexPath) as! SCConfirmChooseCell
            cell.setup(element: element)
            cell.didSelect = { [weak self] in
                self?.didTapChooseTrigger.accept(element)
            }
            return cell
        case .description(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SCConfirmDescriptionCell.self), for: indexPath) as! SCConfirmDescriptionCell
            cell.setup(element: element)
            return cell
        case .continue(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SCSymptomsContinueCell.self), for: indexPath) as! SCSymptomsContinueCell
            cell.setup(element: element)
            return cell
        case .medications(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SCConfirmDrugsCell.self), for: indexPath) as! SCConfirmDrugsCell
            cell.setup(element: element)
            cell.tagsView.didTap = { [weak self] unit in
                guard case let .symptomMed(med) = unit else {
                    return
                }
                
                self?.didRemoveMedicationTrigger.accept(med)
            }
            return cell
        case .conditions(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SCConfirmDrugsCell.self), for: indexPath) as! SCConfirmDrugsCell
            cell.setup(element: element)
            cell.tagsView.didTap = { [weak self] unit in
                guard case let .medicalState(state) = unit else {
                    return
                }
                
                self?.didRemoveConditionTrigger.accept(state)
            }
            return cell
        }
    }
}

extension SCConfirmTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case .continue = elements[indexPath.row] else {
            return
        }
        
        didTapContinueTrigger.accept(Void())
    }
}

// MARK: Private
private extension SCConfirmTableView {
    func initialize() {
        register(SCConfirmMostSymptomCell.self, forCellReuseIdentifier: String(describing: SCConfirmMostSymptomCell.self))
        register(SCConfirmPregnantCell.self, forCellReuseIdentifier: String(describing: SCConfirmPregnantCell.self))
        register(SCConfirmChooseCell.self, forCellReuseIdentifier: String(describing: SCConfirmChooseCell.self))
        register(SCConfirmDescriptionCell.self, forCellReuseIdentifier: String(describing: SCConfirmDescriptionCell.self))
        register(SCSymptomsContinueCell.self, forCellReuseIdentifier: String(describing: SCSymptomsContinueCell.self))
        register(SCConfirmDrugsCell.self, forCellReuseIdentifier: String(describing: SCConfirmDrugsCell.self))
        
        dataSource = self
        delegate = self
    }
}
