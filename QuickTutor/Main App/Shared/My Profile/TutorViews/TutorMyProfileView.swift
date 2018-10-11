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

class TutorMyProfileView: MainLayoutTitleTwoButton {
	var editButton = NavbarButtonEdit()
	var backButton = NavbarButtonBack()
	
	override var leftButton: NavbarButton {
		get { return backButton }
		set { backButton = newValue as! NavbarButtonBack }
	}
	
	override var rightButton: NavbarButton {
		get { return editButton }
		set { editButton = newValue as! NavbarButtonEdit }
	}
	
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
	let myProfileReviews = MyProfileReviewsView()
	let myProfilePolicies = TutorMyProfilePolicies()
	
	override func configureView() {
		addSubview(scrollView)
		scrollView.addSubview(myProfileHeader)
		scrollView.addSubview(myProfileBioView)
		scrollView.addSubview(myProfileBody)
		scrollView.addSubview(myProfileSubjects)
		scrollView.addSubview(myProfileReviews)
		scrollView.addSubview(myProfilePolicies)
		
		super.configureView()
		insertSubview(statusbarView, at: 1)
		insertSubview(navbar, at: 2)
		
		title.label.text = "My Profile"
		
		navbar.backgroundColor = Colors.tutorBlue
		statusbarView.backgroundColor = Colors.tutorBlue
		backgroundColor = Colors.navBarColor
		myProfileReviews.isViewing = isViewing
		
		setupViewForTutor()
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		scrollView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-1)
			make.width.centerX.height.equalToSuperview()
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
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}