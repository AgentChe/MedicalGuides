//
//  BookmarkConditionCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import UIKit

final class BookmarkConditionCell: UITableViewCell {
    lazy var checkedView = makeCheckedView()
    lazy var container = makeContainer()
    lazy var nameLabel = makeLabel()
    lazy var arrowView = makeArrowView()
    
    private lazy var containerLeadingConstraint = NSLayoutConstraint()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.bold(size: 21.scale))
        .lineHeight(28.69.scale)
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
extension BookmarkConditionCell {
    func setup(condition: SymptomsInteractionConditionDetails, selected: Bool?) {
        nameLabel.attributedText = condition.name.attributed(with: attrs)
        
        checkedView.image = UIImage(named: selected == true ? "Bookmark.Checked" : "Bookmark.Unchecked")
        checkedView.isHidden = selected == nil
        
        containerLeadingConstraint.isActive = false
        containerLeadingConstraint.constant = selected == nil ? 16.scale : 42.scale
        containerLeadingConstraint.isActive = true
        
        layoutIfNeeded()
    }
}

// MARK: Private
private extension BookmarkConditionCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension BookmarkConditionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            checkedView.widthAnchor.constraint(equalToConstant: 18.scale),
            checkedView.heightAnchor.constraint(equalToConstant: 19.scale),
            checkedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            checkedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        containerLeadingConstraint = container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale)
        NSLayoutConstraint.activate([
            containerLeadingConstraint,
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -40.scale),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20.scale),
            nameLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20.scale)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 8.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 14.scale),
            arrowView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrowView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension BookmarkConditionCell {
    func makeCheckedView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 20.scale
        view.backgroundColor = Appearance.white
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
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Bookmark.Arrow.Right")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
