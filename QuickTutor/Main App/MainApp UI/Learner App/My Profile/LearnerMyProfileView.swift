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
		return scrollView
	}()
	
	let tableView: UITableView = {
		let tableView = UITableView()
		
		tableView.backgroundColor = .clear
		tableView.estimatedRowHeight = 250
		tableView.isScrollEnabled = true
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		
		return tableView
	}()
	
	let profilePics: TutorCardProfilePic = {
		let view = TutorCardProfilePic()
		
		view.isUserInteractionEnabled = true
		view.backgroundColor = .clear
		
		return view
	}()
	
	let nameContainer: UIView = {
		let view = UIView()
		return view
	}()
	
	let name: UILabel = {
		var label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createBoldSize(20)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	override func configureView() {
		addSubview(scrollView)
		
		addSubview(profilePics)
		profilePics.addSubview(nameContainer)
		nameContainer.addSubview(name)
		addSubview(tableView)
		super.configureView()
		insertSubview(statusbarView, at: 1)
		insertSubview(navbar, at: 2)
		
		title.label.text = "My Profile"
		navbar.backgroundColor = Colors.learnerPurple
		statusbarView.backgroundColor = Colors.learnerPurple
		backgroundColor = Colors.registrationDark
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		profilePics.roundCorners(.allCorners, radius: 8)
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		tableView.snp.makeConstraints { make in
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.top.equalTo(navbar.snp.bottom)
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide)
			} else {
				make.bottom.equalToSuperview()
			}
		}
	}
}
