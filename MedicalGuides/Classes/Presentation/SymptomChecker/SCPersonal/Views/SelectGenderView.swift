//
//  SelectGenderView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 24.05.2023.
//

import UIKit

final class SelectGenderView: UIView {
    enum Gender {
        case male, female
        
        var code: Int {
            switch self {
            case .male:
                return 0
            case .female:
                return 1
            }
        }
    }
    
    lazy var gender = Gender.male {
        didSet {
            update(animate: true)
        }
    }
    
    lazy var selector = makeSelector()
    lazy var maleButton = makeButton()
    lazy var femaleButton = makeButton()
    
    private lazy var selectorLeadingConstraint = NSLayoutConstraint()
    private lazy var selectorTrailingConstraint = NSLayoutConstraint()
    
    private lazy var selectedAttrs = TextAttributes()
        .textColor(Appearance.white)
        .font(Fonts.Avenir.regular(size: 15.scale))
    private lazy var unselectedAttrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.regular(size: 15.scale))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        update(animate: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension SelectGenderView {
    func update(animate: Bool) {
        updatePosition(animate: animate)
        updateText()
    }
    
    func updatePosition(animate: Bool) {
        NSLayoutConstraint.deactivate([
            selectorLeadingConstraint,
            selectorTrailingConstraint
        ])
        
        switch gender {
        case .male:
            selectorLeadingConstraint = selector.leadingAnchor.constraint(equalTo: leadingAnchor)
            selectorTrailingConstraint = selector.trailingAnchor.constraint(equalTo: centerXAnchor)
        case .female:
            selectorLeadingConstraint = selector.leadingAnchor.constraint(equalTo: centerXAnchor)
            selectorTrailingConstraint = selector.trailingAnchor.constraint(equalTo: trailingAnchor)
        }
        
        NSLayoutConstraint.activate([
            selectorLeadingConstraint,
            selectorTrailingConstraint
        ])
        
        if animate {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.layoutIfNeeded()
            })
        } else {
            layoutIfNeeded()
        }
    }
    
    func updateText() {
        let maleAttrs = gender == .male ? selectedAttrs : unselectedAttrs
        maleButton.setAttributedTitle("SymptomChecker.Personal.Male".localized.attributed(with: maleAttrs), for: .normal)
        
        let femaleAttrs = gender == .female ? selectedAttrs : unselectedAttrs
        femaleButton.setAttributedTitle("SymptomChecker.Personal.Female".localized.attributed(with: femaleAttrs), for: .normal)
    }
}

// MARK: Make constraints
private extension SelectGenderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            selector.topAnchor.constraint(equalTo: topAnchor),
            selector.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            maleButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            maleButton.trailingAnchor.constraint(equalTo: centerXAnchor),
            maleButton.topAnchor.constraint(equalTo: topAnchor),
            maleButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            femaleButton.leadingAnchor.constraint(equalTo: centerXAnchor),
            femaleButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            femaleButton.topAnchor.constraint(equalTo: topAnchor),
            femaleButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SelectGenderView {
    func makeSelector() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 10.scale
        view.backgroundColor = Appearance.primary
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeButton() -> UIButton {
        let view = UIButton()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
