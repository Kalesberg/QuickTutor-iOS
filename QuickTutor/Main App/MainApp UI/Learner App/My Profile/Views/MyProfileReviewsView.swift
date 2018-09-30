//
//  MyProfileReviewsView.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class MyProfileReviewsView : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}

	let review : UILabel = {
		let label = UILabel()
		label.font = Fonts.createBoldSize(16)
		label.textColor = Colors.currentUserColor()
		return label
	}()

	
	let tableView: UITableView = {
		let tableView = UITableView()

		tableView.backgroundColor = Colors.navBarColor
		tableView.rowHeight = 70
		tableView.separatorColor = Colors.navBarColor
		tableView.separatorInset.left = 0
		tableView.isScrollEnabled = false
		tableView.allowsSelection = false
		tableView.delaysContentTouches = true
		tableView.tableFooterView = UIView()
		
		return tableView
	}()
	
	let seeAllButton : UIButton = {
		let button = UIButton()
		
		button.setTitle("See All »", for: .normal)
		button.titleLabel?.textColor = Colors.lightGrey
		button.titleLabel?.font = Fonts.createSize(14)
		
		return button
	}()
	
	func configureView() {
		addSubview(review)
		addSubview(tableView)
		addSubview(seeAllButton)
		
		applyConstraints()
	}
	
	func applyConstraints() {
		review.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview().inset(12)
			make.width.equalToSuperview()
			make.height.equalTo(30)
		}
		seeAllButton.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.right.equalToSuperview().inset(12)
			make.width.equalTo(60)
			make.height.equalTo(30)
		}
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(review.snp.bottom).inset(-5)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(120)
		}
	}
}
