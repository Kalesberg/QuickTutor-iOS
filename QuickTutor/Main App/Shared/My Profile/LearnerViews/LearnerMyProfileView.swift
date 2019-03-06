//
//  LearnerProfileView.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class LearnerMyProfileView: UIView {
	
	let scrollView : UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.showsVerticalScrollIndicator = false
		scrollView.alwaysBounceVertical = true
		scrollView.canCancelContentTouches = true
		scrollView.isDirectionalLockEnabled = true
		scrollView.isExclusiveTouch = false
		return scrollView
	}()
	
	let myProfileHeader = LearnerMyProfileHeader()
	let myProfileBioView = MyProfileBioView()
	let myProfileBody = MyProfileBody()
	let myProfileReviews = LearnerMyProfileReviewsView()
	
    func configureView() {
		addSubview(scrollView)
		scrollView.addSubview(myProfileHeader)
		scrollView.addSubview(myProfileBioView)
		scrollView.addSubview(myProfileBody)
		scrollView.addSubview(myProfileReviews)
        backgroundColor = Colors.navBarColor
		
		setupViewForLearner()
		applyConstraints()
	}
	
    func applyConstraints() {
		scrollView.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.centerX.height.equalToSuperview()
		}
		myProfileHeader.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview().inset(1)
			make.height.equalTo((UIScreen.main.bounds.height < 570) ? 220 : 260)
		}
		myProfileBioView.snp.makeConstraints { (make) in
			make.top.equalTo(myProfileHeader.snp.bottom)
			make.width.centerX.equalToSuperview()
		}
		myProfileBody.snp.makeConstraints { (make) in
			make.top.equalTo(myProfileBioView.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(myProfileBody.baseHeight)
		}
		layoutIfNeeded()
	}
	private func setupViewForLearner() {
		myProfileBioView.aboutMeLabel.textColor = Colors.purple
		myProfileBody.additionalInformation.textColor = Colors.purple
		myProfileReviews.reviewTitle.textColor = Colors.purple
		myProfileReviews.reviewLabel1.nameLabel.textColor = Colors.purple
		myProfileReviews.reviewLabel2.nameLabel.textColor = Colors.purple
	}
	override func layoutSubviews() {
		super.layoutSubviews()
	}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
