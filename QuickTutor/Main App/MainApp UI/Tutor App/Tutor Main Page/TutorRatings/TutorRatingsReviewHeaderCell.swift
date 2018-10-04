//
//  TutorRatingsReviewHeaderCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorRatingsReviewHeaderCell: TutorRatingsHeaderCell {
    
    var reviews = [Review]()
    
    let seeAllButton : UIButton = {
        let button = UIButton()
        button.setTitle("See All »", for: .normal)
        button.titleLabel?.textColor = Colors.lightGrey
        button.titleLabel?.font = Fonts.createSize(12)
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        setupSeeAllButton()
    }
    
    func setupSeeAllButton() {
        addSubview(seeAllButton)
        seeAllButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 64, height: 24)
        seeAllButton.addTarget(self, action: #selector(showAllReviews), for: .touchUpInside)
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
}
