//
//  DrugsSearchView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 23.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class DrugsSearchView: UIView {
    lazy var textField = makeTextField()
    lazy var iconView = makeIconView()
    
    private lazy var text = BehaviorRelay(value: "")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        textEditing()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension DrugsSearchView {
    var changedText: Signal<String> {
        text.asSignal(onErrorSignalWith: .never())
    }
}

// MARK: UITextFieldDelegate
extension DrugsSearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Private
private extension DrugsSearchView {
    @objc
    func textEditing() {
        text.accept(textField.text ?? "")
    }
}

// MARK: Make constraints
private extension DrugsSearchView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 15.scale),
            iconView.heightAnchor.constraint(equalToConstant: 15.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DrugsSearchView {
    func makeTextField() -> PaddingTextField {
        let attrs = TextAttributes()
            .textColor(UIColor.black)
            .font(Fonts.Avenir.medium(size: 17.scale))
            .letterSpacing(-0.41.scale)
        
        let placeholderAttrs = TextAttributes()
            .textColor(UIColor(integralRed: 60, green: 60, blue: 67, alpha: 0.6))
            .font(Fonts.Avenir.regular(size: 17.scale))
            .letterSpacing(-0.41.scale)
        
        let view = PaddingTextField()
        view.delegate = self
        view.backgroundColor = UIColor.clear
        view.textPadding = UIEdgeInsets(top: 7.scale, left: 30.scale, bottom: 7.scale, right: 8.scale)
        view.defaultTextAttributes = attrs.dictionary
        view.attributedPlaceholder = "Drugs.Search".localized.attributed(with: placeholderAttrs)
        view.addTarget(self, action: #selector(textEditing), for: .editingChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Drugs.Search")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
