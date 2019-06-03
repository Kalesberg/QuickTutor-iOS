//
//  QuickSearchCategoryCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 1/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

protocol QuickSearchCategoryCellDelegate: class {
    func quickSearchCategoryCell(_ cell: QuickSearchCategoryCell, didSelect subcategory: String, at indexPath: IndexPath)
    func quickSeachCateogryCell(_ cell: QuickSearchCategoryCell, needsHeight height: CGFloat)
}

class QuickSearchCategoryCell: UICollectionViewCell {
    
    var category: Category?
    var showingAllSubcategories = false
    var customHeightAnchor: NSLayoutConstraint?
    weak var delegate: QuickSearchCategoryCellDelegate?
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.newScreenBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceHorizontal = true
        cv.showsHorizontalScrollIndicator = false
        cv.delaysContentTouches = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cv.register(QuickSearchSubcategoryCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    func setupViews() {
        setupMainView()
        setupCollectionView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func updateCollectionViewHeight() {
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        customHeightAnchor?.constant = height
        layoutIfNeeded()
        delegate?.quickSeachCateogryCell(self, needsHeight: 150)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension QuickSearchCategoryCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = category?.subcategory.subcategories.count ?? 0 + 1
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard indexPath.item < 2 else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! QuickSearchSubcategoryCell
//            cell.titleLabel.text = "More"
//            cell.backgroundColor = Colors.newScreenBackground
//            cell.layer.borderColor = Colors.gray.cgColor
//            cell.layer.borderWidth = 1
//            return cell
//        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! QuickSearchSubcategoryCell
        cell.titleLabel.text = category?.subcategory.subcategories[indexPath.item].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 35
        let width = category?.subcategory.subcategories[indexPath.item].title.estimateFrameForFontSize(12).width ?? 0
//        if indexPath.item == 2 {
//            width = 25
//        }
        return CGSize(width: width + 40, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if !showingAllSubcategories && indexPath.item == 2 {
//            showingAllSubcategories = true
//            collectionView.reloadData()
//            updateCollectionViewHeight()
//            return
//        }
        let title = category?.subcategory.subcategories[indexPath.item].title ?? "none"
        let index = IndexPath(item: indexPath.item, section: tag)
        delegate?.quickSearchCategoryCell(self, didSelect: title, at: index)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! QuickSearchSubcategoryCell
        cell.backgroundColor = Colors.gray.darker(by: 30)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! QuickSearchSubcategoryCell
        cell.backgroundColor = Colors.gray
    }
    
}
