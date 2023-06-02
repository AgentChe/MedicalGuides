//
//  SICDetailsFilterView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 31.05.2023.
//

import UIKit

final class SICDetailsFilterView: UIView {
    enum Filter {
        case conditionDetails, treatmentOptions
    }
    
    lazy var filter = Filter.conditionDetails {
        didSet {
            update()
        }
    }
    
    lazy var conditionDetailsButton = makeButton(text: "SICDetails.ConditionDetails".localized)
    lazy var treatmentOptionsButton = makeButton(text: "SICDetails.TreatmentOptions".localized)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension SICDetailsFilterView {
    func update() {
        conditionDetailsButton.marked = filter == .conditionDetails
        treatmentOptionsButton.marked = filter == .treatmentOptions
    }
}

// MARK: Make constraints
private extension SICDetailsFilterView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            conditionDetailsButton.widthAnchor.constraint(equalToConstant: 167.5.scale),
            conditionDetailsButton.heightAnchor.constraint(equalToConstant: 37.scale),
            conditionDetailsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            conditionDetailsButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            treatmentOptionsButton.widthAnchor.constraint(equalToConstant: 167.5.scale),
            treatmentOptionsButton.heightAnchor.constraint(equalToConstant: 37.scale),
            treatmentOptionsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 191.5.scale),
            treatmentOptionsButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SICDetailsFilterView {
    func makeButton(text: String) -> SICDetailsFilterButton {
        let view = SICDetailsFilterButton(text: text)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
