//
//  BookmarkFilterView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import UIKit

final class BookmarkFilterView: UIView {
    enum Filter {
        case drugs, interactions, conditions
    }
    
    lazy var filter = Filter.drugs {
        didSet {
            update()
        }
    }
    
    lazy var drugsButton = makeButton(text: "Bookmark.Drugs".localized)
    lazy var interactionsButton = makeButton(text: "Bookmark.Interactions".localized)
    lazy var conditionsButton = makeButton(text: "Bookmark.Conditions".localized)
    
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
private extension BookmarkFilterView {
    func update() {
        drugsButton.marked = filter == .drugs
        interactionsButton.marked = filter == .interactions
        conditionsButton.marked = filter == .conditions
    }
}

// MARK: Make constraints
private extension BookmarkFilterView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            drugsButton.widthAnchor.constraint(equalToConstant: 112.scale),
            drugsButton.heightAnchor.constraint(equalToConstant: 32.scale),
            drugsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 11.5.scale),
            drugsButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            interactionsButton.widthAnchor.constraint(equalToConstant: 112.scale),
            interactionsButton.heightAnchor.constraint(equalToConstant: 32.scale),
            interactionsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 127.scale),
            interactionsButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            conditionsButton.widthAnchor.constraint(equalToConstant: 112.scale),
            conditionsButton.heightAnchor.constraint(equalToConstant: 32.scale),
            conditionsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 242.5.scale),
            conditionsButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension BookmarkFilterView {
    func makeButton(text: String) -> BookmarkFilterButton {
        let view = BookmarkFilterButton(text: text)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
