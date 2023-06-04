//
//  BookmarkEmptyView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import UIKit

// TODO: актуализировать в соответствии с дизайном
final class BookmarkEmptyView: UIView {
    enum Unit {
        case drugs, interactions, conditions
    }
    
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeLabel()
    lazy var subTitleLabel = makeLabel()
    lazy var button = makeButton()
    
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
            titleLabel.text = "Drugs"
        case .interactions:
            titleLabel.text = "Interactions"
        case .conditions:
            titleLabel.text = "Conditions"
        }
        
//        switch unit {
//        case .spells:
//            imageView.image = UIImage(named: "Bookmarks.Empty.Spells")
//            titleLabel.attributedText = "Bookmarks.Empty.Spells.Title".localized.attributed(with: titleAttrs)
//            subTitleLabel.attributedText = "Bookmarks.Empty.Spells.SubTitle".localized.attributed(with: subTitleAttrs)
//            button.setAttributedTitle("Bookmarks.Empty.Spells.Button".localized.attributed(with: buttonAttrs), for: .normal)
//        case .candles:
//            imageView.image = UIImage(named: "Bookmarks.Empty.Candles")
//            titleLabel.attributedText = "Bookmarks.Empty.Candles.Title".localized.attributed(with: titleAttrs)
//            subTitleLabel.attributedText = "Bookmarks.Empty.Candles.SubTitle".localized.attributed(with: subTitleAttrs)
//            button.setAttributedTitle("Bookmarks.Empty.Candles.Button".localized.attributed(with: buttonAttrs), for: .normal)
//        case .herbs:
//            imageView.image = UIImage(named: "Bookmarks.Empty.Herbs")
//            titleLabel.attributedText = "Bookmarks.Empty.Herbs.Title".localized.attributed(with: titleAttrs)
//            subTitleLabel.attributedText = "Bookmarks.Empty.Herbs.SubTitle".localized.attributed(with: subTitleAttrs)
//            button.setAttributedTitle("Bookmarks.Empty.Herbs.Button".localized.attributed(with: buttonAttrs), for: .normal)
//        case .crystals:
//            imageView.image = UIImage(named: "Bookmarks.Empty.Crystals")
//            titleLabel.attributedText = "Bookmarks.Empty.Crystals.Title".localized.attributed(with: titleAttrs)
//            subTitleLabel.attributedText = "Bookmarks.Empty.Crystals.SubTitle".localized.attributed(with: subTitleAttrs)
//            button.setAttributedTitle("Bookmarks.Empty.Crystals.Button".localized.attributed(with: buttonAttrs), for: .normal)
//        }
    }
}

// MARK: Make constraints
private extension BookmarkEmptyView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 146.scale),
            imageView.heightAnchor.constraint(equalToConstant: 122.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 149.scale : 100.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 13.scale)
        ])
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 226.scale),
            button.heightAnchor.constraint(equalToConstant: 47.scale),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 16.scale)
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
    
    func makeButton() -> UIButton {
        let view = UIButton()
        view.backgroundColor = Appearance.primary
        view.layer.cornerRadius = 23.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
