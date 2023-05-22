//
//  SearchView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchView: UIView {
    lazy var textField = makeTextField()
    lazy var clearButton = makeClearButton()
    
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
extension SearchView {
    var changedText: Signal<String> {
        text.asSignal(onErrorSignalWith: .never())
    }
}

// MARK: UITextFieldDelegate
extension SearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Private
private extension SearchView {
    @objc
    func clearTapped() {
        textField.text = ""
        textEditing()
    }
    
    @objc
    func textEditing() {
        clearButton.isHidden = (textField.text ?? "").isEmpty
        
        text.accept(textField.text ?? "")
    }
}

// MARK: Make constraints
private extension SearchView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -45.scale),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            clearButton.widthAnchor.constraint(equalToConstant: 21.scale),
            clearButton.heightAnchor.constraint(equalToConstant: 20.scale),
            clearButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SearchView {
    func makeTextField() -> PaddingTextField {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.regular(size: 15.scale))
            .lineHeight(21.scale)
        
        let placeholderAttrs = TextAttributes()
            .textColor(Appearance.black.withAlphaComponent(0.4))
            .font(Fonts.Avenir.regular(size: 15.scale))
            .lineHeight(21.scale)
        
        let view = PaddingTextField()
        view.delegate = self
        view.backgroundColor = UIColor.clear
        view.textPadding = UIEdgeInsets.zero
        view.defaultTextAttributes = attrs.dictionary
        view.attributedPlaceholder = "SelectUnit.Search.Placeholder".localized.attributed(with: placeholderAttrs)
        view.addTarget(self, action: #selector(textEditing), for: .editingChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeClearButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "SelectUnit.Clear"), for: .normal)
        view.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
