//
//  TutorRatingsReviewContainerCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorRatingsReviewContainerCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var reviews = [Review]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.registrationDark
        cv.layer.cornerRadius = 8
        cv.clipsToBounds = true
        cv.isScrollEnabled = false
        cv.register(TutorRatingsReviewCell.self, forCellWithReuseIdentifier: "ratingsCell")
        return cv
    }()
    
    let seeAllButton = SeeAllButton()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ratingsCell", for: indexPath) as! TutorRatingsReviewCell
        cell.updateUI(review: reviews[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func setupViews() {
        setupCollectionView()
        setupSeeAllButton()
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 180)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupSeeAllButton() {
        addSubview(seeAllButton)
        seeAllButton.label.font = Fonts.createSize(12)
        seeAllButton.anchor(top: collectionView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 64, height: 24)
        let tap = UITapGestureRecognizer(target: self, action: #selector(showAllReviews))
        seeAllButton.addGestureRecognizer(tap)
    }
    
    @objc func showAllReviews() {
        if let current = UIApplication.getPresentedViewController() {
            let next = LearnerReviewsVC()
            next.isViewing = true
            next.contentView.navbar.backgroundColor = Colors.gold
            next.contentView.statusbarView.backgroundColor = Colors.gold
            next.datasource = reviews
            current.present(next, animated: true, completion: nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

