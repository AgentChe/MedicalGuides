//
//  SCSymptomsTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 25.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SCSymptomsTableView: UITableView {
    lazy var elements = [SCSymptomsTableElement]()
    
    private lazy var didTapSelectTrigger = PublishRelay<Void>()
    private lazy var didTapContinueTrigger = PublishRelay<Void>()
    private lazy var didRemoveSymptomTrigger = PublishRelay<Symptom>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SCSymptomsTableView {
    func setup(elements: [SCSymptomsTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapSelect: Signal<Void> {
        didTapSelectTrigger.asSignal()
    }
    
    var didTapContinue: Signal<Void> {
        didTapContinueTrigger.asSignal()
    }
    
    var didRemoveSymptom: Signal<Symptom> {
        didRemoveSymptomTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SCSymptomsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .select:
            return dequeueReusableCell(withIdentifier: String(describing: SCSymptomsSelectCell.self), for: indexPath)
        case .symptoms(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SCSymptomsTagsCell.self), for: indexPath) as! SCSymptomsTagsCell
            cell.setup(element: element)
            cell.tagsView.didTap = { [weak self] symptom in
                self?.didRemoveSymptomTrigger.accept(symptom)
            }
            return cell
        case .continue(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: SCSymptomsContinueCell.self), for: indexPath) as! SCSymptomsContinueCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension SCSymptomsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .select:
            didTapSelectTrigger.accept(Void())
        case .continue(let element):
            guard element else {
                return
            }
            
            didTapContinueTrigger.accept(Void())
        default:
            return
        }
    }
}

// MARK: Private
private extension SCSymptomsTableView {
    func initialize() {
        register(SCSymptomsSelectCell.self, forCellReuseIdentifier: String(describing: SCSymptomsSelectCell.self))
        register(SCSymptomsContinueCell.self, forCellReuseIdentifier: String(describing: SCSymptomsContinueCell.self))
        register(SCSymptomsTagsCell.self, forCellReuseIdentifier: String(describing: SCSymptomsTagsCell.self))
        
        dataSource = self
        delegate = self
    }
}
