//
//  ReceiptCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class SessionSummaryView : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
	}
	
	let title : UILabel = {
		let label = UILabel()

		label.text = "Session Summary"
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(18)
		
		return label
	}()
	
}

class ReceiptCell : UICollectionViewCell {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureCollectionViewCell()
	}
	
	let containerView : UIView = {
		let view = UIView()
		
		view.backgroundColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple : Colors.tutorBlue
		
		return view
	}()
	
	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Session Receipt"
		label.textColor = .white
		label.font = Fonts.createBoldSize(20)
		label.textAlignment = .center
		
		return label
	}()
	
	func configureCollectionViewCell() {
		addSubview(containerView)
		containerView.addSubview(title)
		applyConstraints()
	}
	
	func applyConstraints() {
		containerView.snp.makeConstraints { (make) in
			make.top.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.95)
			make.height.equalToSuperview().multipliedBy(0.5)
		}
		title.snp.makeConstraints { (make) in
			make.top.centerX.width.equalToSuperview()
			make.height.equalTo(35)
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		containerView.layer.cornerRadius = 8
	}
}
