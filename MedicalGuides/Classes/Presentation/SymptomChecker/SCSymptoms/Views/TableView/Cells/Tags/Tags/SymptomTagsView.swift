//
//  SymptomTagsView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 26.05.2023.
//

import UIKit

final class SymptomTagsView: UIView {
    let width = 343.scale
    
    var didTap: ((Symptom) -> Void)?
    
    private var tagViews: [SymptomTagView] = []
    private var rowViews: [UIView] = []
    private var tagViewHeight: CGFloat = 0
    private var rows = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override func layoutSubviews() {
        defer { rearrangeViews() }
        super.layoutSubviews()
    }
    
    override var intrinsicContentSize: CGSize {
        var height = CGFloat(rows) * (tagViewHeight + 10.scale)
        if rows > 0 {
            height -= 10.scale
        }
        return CGSize(width: width, height: height)
    }
}

// MARK: Public
extension SymptomTagsView {
    func addTags(_ symptoms: [Symptom]) {
        let views = symptoms.map { createNewTagView($0) }
        
        views.forEach {
            tagViews.append($0)
        }
        
        rearrangeViews()
    }
    
    func removeTag(_ symptom: Symptom) {
        tagViews
            .reversed()
            .filter { $0.symptom.id == symptom.id }
            .forEach { removeTagView($0) }
    }
    
    func removeAllTags() {
        defer {
            tagViews = []
            rearrangeViews()
        }
        
        tagViews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: Private
private extension SymptomTagsView {
    @objc
    func didTapView(sender: UIButton) {
        guard let button = sender as? SymptomTagView else {
            return
        }
        
        didTap?(button.symptom)
    }
    
    func createNewTagView(_ symptom: Symptom) -> SymptomTagView {
        let view = SymptomTagView(symptom: symptom)
        view.layer.cornerRadius = 8.scale
        view.layer.masksToBounds = true
        view.titleEdgeInsets = UIEdgeInsets(top: 12.scale, left: 16.scale, bottom: 12.scale, right: 50.scale)
        view.backgroundColor =  Appearance.primary.withAlphaComponent(0.15)
        view.frame.size = view.intrinsicContentSize
        view.addTarget(self, action: #selector(didTapView(sender:)), for: .touchUpInside)
        return view
    }
    
    func rearrangeViews() {
        let views = tagViews as [UIView] + rowViews
        views.forEach {
            $0.removeFromSuperview()
        }
        rowViews.removeAll(keepingCapacity: true)
        
        var currentRow = 0
        var currentRowView: UIView!
        var currentRowTagCount = 0
        var currentRowWidth: CGFloat = 0
        
        for tagView in tagViews {
            tagView.frame.size = tagView.intrinsicContentSize
            tagViewHeight = tagView.frame.height
            
            if currentRowTagCount == 0 || currentRowWidth + tagView.frame.width > width {
                currentRow += 1
                currentRowWidth = 0
                currentRowTagCount = 0
                currentRowView = UIView()
                currentRowView.frame.origin.y = CGFloat(currentRow - 1) * (tagViewHeight + 10.scale)
                
                rowViews.append(currentRowView)
                addSubview(currentRowView)

                tagView.frame.size.width = min(tagView.frame.size.width, width)
            }
            
            tagView.frame.origin = CGPoint(x: currentRowWidth, y: 0)
            currentRowView.addSubview(tagView)
            
            currentRowTagCount += 1
            currentRowWidth += tagView.frame.width + 10.scale
            currentRowView.frame.origin.x = 0
            currentRowView.frame.size.width = currentRowWidth
            currentRowView.frame.size.height = max(tagViewHeight, currentRowView.frame.height)
        }
        rows = currentRow
        
        invalidateIntrinsicContentSize()
    }
    
    func removeTagView(_ tagView: SymptomTagView) {
        defer {
            rearrangeViews()
        }
        
        tagView.removeFromSuperview()
        
        if let index = tagViews.firstIndex(of: tagView) {
            tagViews.remove(at: index)
        }
    }
}
