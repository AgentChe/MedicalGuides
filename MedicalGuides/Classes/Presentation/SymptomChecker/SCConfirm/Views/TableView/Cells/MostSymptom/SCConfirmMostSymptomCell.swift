//
//  SCConfirmMostSymptomCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 26.05.2023.
//

import UIKit

final class SCConfirmMostSymptomCell: UITableViewCell {
    var didSelect: ((Symptom) -> Void)?
    
    lazy var titleLabel = makeTitleLabel()
    lazy var stackView = makeStackView()
    
    private lazy var symptomButtons = [MostSymptomButton]()
    
    private var element: SCConfirmMostSymptomElement!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SCConfirmMostSymptomCell {
    func setup(element: SCConfirmMostSymptomElement) {
        self.element = element
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        symptomButtons = []
        
        element.symptoms.forEach { symptom in
            let view = MostSymptomButton(symptom: symptom)
            view.backgroundColor = Appearance.white
            view.layer.cornerRadius = 10.scale
            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(view)
            
            view.marked = symptom.id == element.mostSymptomId
            
            view.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            
            symptomButtons.append(view)
            
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: 343.scale)
            ])
        }
    }
}

// MARK: Private
private extension SCConfirmMostSymptomCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func buttonTapped(sender: UIButton) {
        guard let button = sender as? MostSymptomButton else {
            return
        }
        
        symptomButtons.forEach { $0.marked = false }
        button.marked = true
        
        element.mostSymptomId = button.symptom.id
        
        didSelect?(button.symptom)
    }
}

// MARK: Make constraints
private extension SCConfirmMostSymptomCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15.scale)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.scale),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SCConfirmMostSymptomCell {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.bold(size: 21.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "SymptomChecker.Confirm.MostSymptom".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 16.scale
        view.backgroundColor = UIColor.clear
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets.zero
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
