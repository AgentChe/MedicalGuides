//
//  PregnantView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 29.05.2023.
//

import UIKit

final class PregnantView: UIView {
    lazy var pregnant = false {
        didSet {
            update(animate: true)
        }
    }
    
    lazy var selector = makeSelector()
    lazy var noButton = makeButton()
    lazy var yesButton = makeButton()
    
    private lazy var selectorLeadingConstraint = NSLayoutConstraint()
    private lazy var selectorTrailingConstraint = NSLayoutConstraint()
    
    private lazy var selectedAttrs = TextAttributes()
        .textColor(Appearance.white)
        .font(Fonts.Avenir.regular(size: 15.scale))
    private lazy var unselectedAttrs = TextAttributes()
        .textColor(UIColor(integralRed: 31, green: 31, blue: 33))
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
private extension PregnantView {
    func update(animate: Bool) {
        updatePosition(animate: animate)
        updateText()
    }
    
    func updatePosition(animate: Bool) {
        NSLayoutConstraint.deactivate([
            selectorLeadingConstraint,
            selectorTrailingConstraint
        ])
        
        switch pregnant {
        case false:
            selectorLeadingConstraint = selector.leadingAnchor.constraint(equalTo: leadingAnchor)
            selectorTrailingConstraint = selector.trailingAnchor.constraint(equalTo: centerXAnchor)
        case true:
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
        let noAttrs = !pregnant ? selectedAttrs : unselectedAttrs
        noButton.setAttributedTitle("SymptomChecker.Confirm.No".localized.attributed(with: noAttrs), for: .normal)
        
        let yesAttrs = pregnant ? selectedAttrs : unselectedAttrs
        yesButton.setAttributedTitle("SymptomChecker.Confirm.Yes".localized.attributed(with: yesAttrs), for: .normal)
    }
}

// MARK: Make constraints
private extension PregnantView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            selector.topAnchor.constraint(equalTo: topAnchor),
            selector.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            noButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            noButton.trailingAnchor.constraint(equalTo: centerXAnchor),
            noButton.topAnchor.constraint(equalTo: topAnchor),
            noButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            yesButton.leadingAnchor.constraint(equalTo: centerXAnchor),
            yesButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            yesButton.topAnchor.constraint(equalTo: topAnchor),
            yesButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PregnantView {
    func makeSelector() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 8.scale
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
