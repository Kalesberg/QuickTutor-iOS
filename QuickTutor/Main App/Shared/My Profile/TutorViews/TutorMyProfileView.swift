//
//  TutorMyProfileView.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class TutorMyProfileView: UIView {
	
	var isViewing : Bool = false
	
	let scrollView : UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.showsVerticalScrollIndicator = false
		scrollView.alwaysBounceVertical = true
		scrollView.canCancelContentTouches = true
		scrollView.isDirectionalLockEnabled = true
		scrollView.isExclusiveTouch = false
		return scrollView
	}()
	
	let myProfileHeader = TutorMyProfileHeader()
	let myProfileBioView = MyProfileBioView()
	let myProfileBody = MyProfileBody()
	let myProfileSubjects = TutorMyProfileSubjects()
	let myProfileReviews = TutorMyProfileReviewsView()
	let myProfileNoReviews = NoReviewsView()
	let myProfilePolicies = TutorMyProfilePolicies()
	
    func configureView() {
		addSubview(scrollView)
		scrollView.addSubview(myProfileHeader)
		scrollView.addSubview(myProfileBioView)
		scrollView.addSubview(myProfileBody)
		scrollView.addSubview(myProfileSubjects)
		scrollView.addSubview(myProfileReviews)
		scrollView.addSubview(myProfilePolicies)
		myProfileReviews.isViewing = isViewing
        setupViewForTutor()
        backgroundColor = Colors.darkBackground
	}
	
    func applyConstraints() {
		scrollView.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.centerX.bottom.equalToSuperview()
		}
		myProfileHeader.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview().inset(1)
			make.height.equalTo((UIScreen.main.bounds.height < 570) ? 250 : 290)
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
		myProfileSubjects.snp.makeConstraints { (make) in
			make.top.equalTo(myProfileBody.divider.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(80)
		}
	}
	
	private func setupViewForTutor() {
		myProfileBioView.aboutMeLabel.textColor = Colors.tutorBlue
		myProfileBody.additionalInformation.textColor = Colors.tutorBlue
		myProfileReviews.reviewTitle.textColor = Colors.tutorBlue
		myProfileReviews.reviewLabel1.nameLabel.textColor = Colors.tutorBlue
		myProfileReviews.reviewLabel2.nameLabel.textColor = Colors.tutorBlue
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
