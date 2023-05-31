//
//  MostSymptomButton.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 26.05.2023.
//

import UIKit

final class MostSymptomButton: UIButton {
    lazy var marked = false {
        didSet {
            update()
        }
    }
    
    let symptom: Symptom
    
    lazy var iconView = makeIconView()
    lazy var label = makeLabel()
    
    init(symptom: Symptom) {
        self.symptom = symptom
        
        super.init(frame: .zero)
        
        makeConstraints()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension MostSymptomButton {
    func update() {
        iconView.image = UIImage(named: marked ? "SymptomChecker.Checked" : "SymptomChecker.Unchecked")
    }
}

// MARK: Make constraints
private extension MostSymptomButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20.scale),
            iconView.heightAnchor.constraint(equalToConstant: 20.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 44.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MostSymptomButton {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.regular(size: 15.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = symptom.name.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
