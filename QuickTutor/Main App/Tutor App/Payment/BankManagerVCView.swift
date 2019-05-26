//
//  BankManagerVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class BankManagerVCView: UIView {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.alwaysBounceVertical = true
        cv.register(BankManagerCollectionViewCell.self, forCellWithReuseIdentifier: "bankCell")
        cv.register(EarningsHistoryCell.self, forCellWithReuseIdentifier: "earningsCell")
        cv.register(BankManagerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell")
        return cv
    }()
    
    func setupViews() {
        setupMainView()
        setupCollectionView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: getTopAnchor(), left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
