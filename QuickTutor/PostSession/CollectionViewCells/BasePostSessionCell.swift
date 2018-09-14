//
//  BasePostSessionCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class BasePostSessionCell : UICollectionViewCell {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureCollectionViewCell()
	}
	
	let titleView = SessionReviewHeader()
	let backgroundHeaderView = UIView()
	var headerView = UIView()
	
	var title : UILabel = {
		let label = UILabel()
		
		label.textAlignment = .left
		label.textColor = .white
		label.font = Fonts.createBoldSize(18)
		
		return label
	}()
	
	func configureCollectionViewCell() {
		addSubview(titleView)
		addSubview(backgroundHeaderView)
		backgroundHeaderView.addSubview(headerView)
		headerView.addSubview(title)

		backgroundHeaderView.backgroundColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple : Colors.tutorBlue
		headerView.backgroundColor = Colors.navBarColor
		
		applyConstraints()
	}
	
	func applyConstraints() {
		titleView.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview()
			make.height.equalTo(120)
		}
		backgroundHeaderView.snp.makeConstraints { (make) in
			make.top.equalTo(titleView.snp.bottom).inset(-30)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(50)
		}
		headerView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(4)
			make.top.right.height.equalToSuperview()
		}
		title.snp.makeConstraints { (make) in
			make.centerY.height.width.equalToSuperview()
			make.left.equalToSuperview().inset(5)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		sendSubview(toBack: titleView)
		backgroundHeaderView.roundCorners([.topRight, .topLeft], radius: 4)
	}
}
