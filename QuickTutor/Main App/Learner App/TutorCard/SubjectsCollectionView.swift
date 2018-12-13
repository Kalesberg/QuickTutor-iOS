//
//  SubjectsCollectionView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SubjectsCollectionView: UICollectionView {
    
    let layout: AlignedCollectionViewFlowLayout = {
        let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .center)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        return layout
    }()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        collectionViewLayout = self.layout
        allowsMultipleSelection = false
        isScrollEnabled = false
        isUserInteractionEnabled = false
        backgroundColor = Colors.darkBackground
        register(PillCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
