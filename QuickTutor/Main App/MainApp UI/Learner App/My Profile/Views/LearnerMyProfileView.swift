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

class LearnerMyProfileView: MainLayoutTitleTwoButton {
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
	
	let scrollView : UIScrollView = {
		let scrollView = UIScrollView()
		
		scrollView.showsVerticalScrollIndicator = false
		scrollView.alwaysBounceVertical = true
		scrollView.canCancelContentTouches = true
		scrollView.isDirectionalLockEnabled = true

		return scrollView
	}()
	
	let myProfileHeader = MyProfileHeader()
	let myProfileBioView = MyProfileBioView()
	let myProfileBody = MyProfileBody()
	let myProfileReviews = MyProfileReviewsView()
	
	override func configureView() {
		addSubview(scrollView)
		scrollView.addSubview(myProfileHeader)
		scrollView.addSubview(myProfileBioView)
		scrollView.addSubview(myProfileBody)
		scrollView.addSubview(myProfileReviews)
		
		super.configureView()
		insertSubview(statusbarView, at: 1)
		insertSubview(navbar, at: 2)
		
		title.label.text = "My Profile"
		
		navbar.backgroundColor = Colors.learnerPurple
		statusbarView.backgroundColor = Colors.learnerPurple
		backgroundColor = Colors.navBarColor
		scrollView.contentSize.height = 1400
		
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
			make.height.equalTo((UIScreen.main.bounds.height < 570) ? 210 : 250)
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
		myProfileReviews.snp.makeConstraints { (make) in
			make.top.equalTo(myProfileBody.snp.bottom)
			make.width.centerX.equalToSuperview()
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		
	}
}
