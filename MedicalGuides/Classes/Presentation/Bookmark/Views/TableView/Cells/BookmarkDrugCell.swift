//
//  BookmarkDrugCell.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import UIKit

final class BookmarkDrugCell: UITableViewCell {
    lazy var checkedView = makeCheckedView()
    lazy var nameLabel = makeLabel()
    lazy var arrowView = makeArrowView()
    lazy var separator = makeSeparator()
    
    private lazy var nameLeadingConstraint = NSLayoutConstraint()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.bold(size: 17.scale))
        .lineHeight(23.22.scale)
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
extension BookmarkDrugCell {
    func setup(drug: Drug, selected: Bool?, separatorHidden: Bool) {
        nameLabel.attributedText = drug.name.attributed(with: attrs)
        
        checkedView.image = UIImage(named: selected == true ? "Bookmark.Checked" : "Bookmark.Unchecked")
        checkedView.isHidden = selected == nil
        
        separator.isHidden = separatorHidden
        
        nameLeadingConstraint.isActive = false
        nameLeadingConstraint.constant = selected == nil ? 20.scale : 50.scale
        nameLeadingConstraint.isActive = true
        
        layoutIfNeeded()
    }
}

// MARK: Private
private extension BookmarkDrugCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension BookmarkDrugCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            checkedView.widthAnchor.constraint(equalToConstant: 18.scale),
            checkedView.heightAnchor.constraint(equalToConstant: 19.scale),
            checkedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            checkedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        nameLeadingConstraint = nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale)
        NSLayoutConstraint.activate([
            nameLeadingConstraint,
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40.scale),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 8.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 14.scale),
            arrowView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension BookmarkDrugCell {
    func makeCheckedView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
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
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(integralRed: 218, green: 221, blue: 217)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
