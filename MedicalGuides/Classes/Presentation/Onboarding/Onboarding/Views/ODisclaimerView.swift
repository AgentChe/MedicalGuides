//
//  ODisclaimerView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 05.05.2023.
//

import UIKit

final class ODisclaimerView: OSlideView {
    lazy var disclaimerView = makeDisclaimerView()
    
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ODisclaimerView {
    func initialize() {
        backgroundColor = Appearance.secondary4
    }
}

// MARK: Make constraints
private extension ODisclaimerView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            disclaimerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            disclaimerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            disclaimerView.topAnchor.constraint(equalTo: topAnchor),
            disclaimerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ODisclaimerView {
    func makeDisclaimerView() -> DisclaimerView {
        let view = DisclaimerView(buttonTitle: .continue)
        view.button.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
