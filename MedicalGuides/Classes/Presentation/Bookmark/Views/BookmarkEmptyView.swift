//
//  BookmarkEmptyView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import UIKit

final class BookmarkEmptyView: UIView {
    enum Unit {
        case drugs, interactions, conditions
    }
    
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeLabel()
    lazy var textLabel = makeLabel()
    
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.bold(size: 15.scale))
        .lineHeight(21.scale)
        .textAlignment(.center)
    private lazy var textAttrs = TextAttributes()
        .textColor(UIColor(integralRed: 84, green: 84, blue: 84))
        .font(Fonts.Avenir.regular(size: 15.scale))
        .lineHeight(21.scale)
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension BookmarkEmptyView {
    func setup(unit: Unit) {
        switch unit {
        case .drugs:
            imageView.image = UIImage(named: "Bookmark.Empty.Drugs")
            titleLabel.attributedText = "Bookmark.Empty.Drugs.Title".localized.attributed(with: titleAttrs)
            textLabel.attributedText = "Bookmark.Empty.Drugs.Text".localized.attributed(with: textAttrs)
        case .interactions:
            imageView.image = UIImage(named: "Bookmark.Empty.Interactions")
            titleLabel.attributedText = "Bookmark.Empty.Interactions.Title".localized.attributed(with: titleAttrs)
            textLabel.attributedText = "Bookmark.Empty.Interactions.Text".localized.attributed(with: textAttrs)
        case .conditions:
            imageView.image = UIImage(named: "Bookmark.Empty.Conditions")
            titleLabel.attributedText = "Bookmark.Empty.Conditions.Title".localized.attributed(with: titleAttrs)
            textLabel.attributedText = "Bookmark.Empty.Conditions.Text".localized.attributed(with: textAttrs)
        }
    }
}

// MARK: Make constraints
private extension BookmarkEmptyView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80.scale),
            imageView.heightAnchor.constraint(equalToConstant: 80.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 104.scale)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension BookmarkEmptyView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
