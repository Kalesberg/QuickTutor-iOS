//
//  EditListingView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class EditListingView: MainLayoutTitleBackTwoButton {
	var saveButton = NavbarButtonSave()
	
	override var rightButton: NavbarButton {
		get {
			return saveButton
		} set {
			saveButton = newValue as! NavbarButtonSave
		}
	}
	
	let tableView: UITableView = {
		let tableView = UITableView()
		tableView.estimatedRowHeight = 70
		tableView.showsVerticalScrollIndicator = false
		tableView.alwaysBounceVertical = true
		tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
		return tableView
	}()
	
	let fakeBackground: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(hex: "484782")
		return view
	}()
	
	override func configureView() {
		insertSubview(fakeBackground, belowSubview: navbar)
		insertSubview(tableView, belowSubview: navbar)
		super.configureView()
		navbar.applyDefaultShadow()
		navbar.layer.masksToBounds = false
		navbar.clipsToBounds = false
		bringSubviewToFront(navbar)
		bringSubviewToFront(statusbarView)
		navbar.backgroundColor = Colors.learnerPurple
		statusbarView.backgroundColor = Colors.learnerPurple
		
		title.label.text = "Edit"
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		fakeBackground.snp.makeConstraints { make in
			make.top.equalTo(navbar.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalToSuperview().dividedBy(3)
		}
		tableView.snp.makeConstraints { make in
			make.top.equalTo(navbar.snp.bottom)
			make.width.centerX.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaInsets.bottom)
			} else {
				make.bottom.equalTo(layoutMargins.bottom)
			}
		}
	}
}
