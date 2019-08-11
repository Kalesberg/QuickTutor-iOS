//
//  QuickSearchVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 1/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class QuickSearchVCView: UIView {

    let searchBarContainer: CustomSearchBarContainer = {
        let container = CustomSearchBarContainer()
        container.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: 3), radius: 4)
        return container
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.newScreenBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        cv.delaysContentTouches = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cv.register(QuickSearchCategoryCell.self, forCellWithReuseIdentifier: "cellId")
        cv.register(QuickSearchSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        return cv
    }()
    
    func setupViews() {
        setupMainView()
        setupSearchBarContainer()
        setupCollectionView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
        clipsToBounds = true
    }
    
    func setupSearchBarContainer() {
        insertSubview(searchBarContainer, at: 2)
        addSubview(searchBarContainer)
        searchBarContainer.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 57)
    }
    
    func setupCollectionView() {
        insertSubview(collectionView, at: 0)
        collectionView.anchor(top: searchBarContainer.bottomAnchor, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
