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
        return container
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
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
        backgroundColor = Colors.darkBackground
    }
    
    func setupSearchBarContainer() {
        addSubview(searchBarContainer)
        searchBarContainer.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 53, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 47)

    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: searchBarContainer.bottomAnchor, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
