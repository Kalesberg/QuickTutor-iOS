//
//  Search.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorView: BaseView {
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0

        collectionView.backgroundColor = Colors.backgroundDark
        collectionView.collectionViewLayout = layout
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast

        return collectionView
    }()

    let addPaymentModal = AddPaymentModal()

    override func configureView() {
        addSubview(collectionView)
        addSubview(addPaymentModal)
        super.configureView()

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()

        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        addPaymentModal.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
