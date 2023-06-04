//
//  InteractionCheckerResultCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

import UIKit

final class InteractionCheckerResultCell: UITableViewCell {
    var didTapBookmark: (() -> Void)?
    
    lazy var container = makeContainer()
    lazy var titleLabel = makeLabel()
    lazy var subtitleLabel = makeLabel()
    lazy var label = makeLabel()
    lazy var bookmarkButton = makeBookmarkButton()
    
    private lazy var subtitleAttrs = TextAttributes()
        .textColor(Appearance.black.withAlphaComponent(0.6))
        .font(Fonts.Avenir.bold(size: 15.scale))
        .lineHeight(21.scale)
        .textAlignment(.left)
    private lazy var textAttrs = TextAttributes()
        .textColor(Appearance.black.withAlphaComponent(0.6))
        .font(Fonts.Avenir.regular(size: 15.scale))
        .lineHeight(21.scale)
        .textAlignment(.left)
    
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
extension InteractionCheckerResultCell {
    func setup(element: InteractionCheckerResultElement) {
        let titleAttrs = titleAttrs(at: element.result.sideEffect)
        titleLabel.attributedText = element.result.title.attributed(with: titleAttrs)
        subtitleLabel.attributedText = element.result.subtitle.attributed(with: subtitleAttrs)
        label.attributedText = element.result.text.attributed(with: textAttrs)
        
        let bookmarkImage = UIImage(named: element.marked ? "InteractionChecker.Saved" : "InteractionChecker.Unsaved")
        bookmarkButton.setImage(bookmarkImage, for: .normal)
    }
}

// MARK: Private
private extension InteractionCheckerResultCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    // TODO: цвет в зависимости от side effect
    func titleAttrs(at sideEffect: DrugsSideEffect) -> TextAttributes {
        switch sideEffect {
        case .minor, .monitorClosely, .serious, .dontUseTogether:
            return TextAttributes()
                .textColor(Appearance.secondary1)
                .font(Fonts.Avenir.bold(size: 21.scale))
                .textAlignment(.left)
        }
    }
    
    @objc
    func didTapBookmarkButton() {
        didTapBookmark?()
    }
}

// MARK: Make constraints
private extension InteractionCheckerResultCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -45.scale),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15.scale),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -45.scale),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15.scale),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -45.scale),
            label.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8.scale),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20.scale)
        ])
        
        NSLayoutConstraint.activate([
            bookmarkButton.widthAnchor.constraint(equalToConstant: 12.scale),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 18.scale),
            bookmarkButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15.scale),
            bookmarkButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 20.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension InteractionCheckerResultCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 20.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeBookmarkButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapBookmarkButton), for: .touchUpInside)
        container.addSubview(view)
        return view
    }
}
