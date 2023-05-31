//
//  SymptomTagView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 26.05.2023.
//

import UIKit

final class SymptomTagView: UIButton {
    let symptom: Symptom
    
    lazy var clearView = makeClearView()
    
    private lazy var font = Fonts.Avenir.regular(size: 15.scale)
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.primary)
        .font(font)
        .lineBreakMode(.byTruncatingMiddle)
    
    init(symptom: Symptom) {
        self.symptom = symptom
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        var size = NSString(string: symptom.name).size(withAttributes: attrs.dictionary)
        size.height = font.pointSize + titleEdgeInsets.top + titleEdgeInsets.bottom
        size.width += titleEdgeInsets.left + titleEdgeInsets.right
        if size.width < size.height {
            size.width = size.height
        }
        return size
    }
}

// MARK: Private
private extension SymptomTagView {
    func initialize() {
        setAttributedTitle(symptom.name.attributed(with: attrs), for: .normal)
    }
}

// MARK: Make constraints
private extension SymptomTagView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            clearView.widthAnchor.constraint(equalToConstant: 11.scale),
            clearView.heightAnchor.constraint(equalToConstant: 12.scale),
            clearView.centerYAnchor.constraint(equalTo: centerYAnchor),
            clearView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SymptomTagView {
    func makeClearView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "SymptomChecker.Clear")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

