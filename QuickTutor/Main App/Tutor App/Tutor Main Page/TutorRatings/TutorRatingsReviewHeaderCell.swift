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
	var parentViewController : UIViewController?
	
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
		let vc = LearnerReviewsVC()
		vc.isViewing = true
		vc.contentView.navbar.backgroundColor = Colors.gold
		vc.contentView.statusbarView.backgroundColor = Colors.gold
		vc.datasource = reviews
		let nav = parentViewController?.navigationController
		DispatchQueue.main.async {
			nav?.view.layer.add(CATransition().segueFromBottom(), forKey: nil)
			nav?.pushViewController(vc, animated: false)
		}
	}
}
