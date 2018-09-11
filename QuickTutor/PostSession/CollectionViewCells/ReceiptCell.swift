//
//  ReceiptCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class PersonalProgressView : UIView {
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Personal Progress"
		label.textColor = Colors.learnerPurple
		label.textAlignment = .right
		label.font = Fonts.createSize(15)
		label.sizeToFit()
		
		return label
	}()
	
	let totalSessions : UILabel = {
		let label = UILabel()
		
		label.text = "Text"
		label.textColor = Colors.learnerPurple
		label.textAlignment = .right
		label.font = Fonts.createSize(15)
		label.sizeToFit()
		
		return label
	}()
	
	let totalSessionsWithTutor : UILabel = {
		let label = UILabel()
		
		label.text = "Text"
		label.textColor = Colors.learnerPurple
		label.textAlignment = .right
		label.font = Fonts.createSize(15)
		label.sizeToFit()
		
		return label
	}()
	
	func configureView() {
		addSubview(title)
		addSubview(totalSessions)
		addSubview(totalSessionsWithTutor)
		
		backgroundColor = .red
		applyConstraints()
	}
	func applyConstraints() {
		title.snp.makeConstraints { (make) in
			make.top.left.equalToSuperview().inset(10)
		}
		totalSessions.snp.makeConstraints { (make) in
			make.top.equalTo(title.snp.bottom)
			make.width.equalToSuperview()
			make.height.equalTo(20)
		}
		totalSessionsWithTutor.snp.makeConstraints { (make) in
			make.top.equalTo(totalSessions.snp.bottom)
			make.width.equalToSuperview()
			make.height.equalTo(20)
		}
	}
}

class SessionReceiptItemWithImage : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Text"
		label.textColor = Colors.learnerPurple
		label.textAlignment = .right
		label.font = Fonts.createSize(15)
		label.sizeToFit()
		
		return label
	}()
	
	let infoLabel : UILabel = {
		let label = UILabel()
		
		label.text = "Text"
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createSize(15)
		label.sizeToFit()
		
		return label
	}()
	
	let profileImageView = UIImageView()

	func configureView() {
		addSubview(title)
		addSubview(infoLabel)
		addSubview(profileImageView)
		
		profileImageView.backgroundColor = .red
		applyConstraints()
	}
	func applyConstraints() {
		title.snp.makeConstraints { (make) in
			make.top.left.equalToSuperview()
		}
		profileImageView.snp.makeConstraints { (make) in
			make.width.height.equalTo(50)
			make.centerY.equalTo(title.snp.centerY)
			make.left.equalTo(title.snp.right).inset(5)
		}
		infoLabel.snp.makeConstraints { (make) in
			make.left.equalTo(profileImageView.snp.right).inset(5)
			make.centerY.equalTo(profileImageView.snp.centerY)
		}
	}
}
class SessionReceiptItem : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Text"
		label.textColor = Colors.learnerPurple
		label.textAlignment = .right
		label.font = Fonts.createSize(15)
		label.sizeToFit()
		
		return label
	}()
	
	let infoLabel : UILabel = {
		let label = UILabel()
		
		label.text = "Text"
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createSize(15)
		label.sizeToFit()
		
		return label
	}()
	
	func configureView() {
		addSubview(title)
		addSubview(infoLabel)
		
		applyConstraints()
	}
	func applyConstraints() {
		title.snp.makeConstraints { (make) in
			make.top.left.equalToSuperview()
		}
		infoLabel.snp.makeConstraints { (make) in
			make.left.equalTo(title.snp.right).inset(5)
			make.centerY.equalTo(title.snp.centerY)
		}
	}
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
	
	let sessionSummaryContainer : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.navBarColor
		return view
	}()
	
	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Your Receipt"
		label.textColor = .white
		label.font = Fonts.createBoldSize(18)
		label.textAlignment = .center
		
		return label
	}()
	
	let subtitle : UILabel = {
		let label = UILabel()
		
		label.text = "Session Summary"
		label.textColor = .white
		label.font = Fonts.createBoldSize(17)
		label.textAlignment = .left
		
		return label
	}()
	
	let infoContainer = UIView()
	let partner = SessionReceiptItemWithImage()
	var userType = SessionReceiptItem()
	var subject = SessionReceiptItem()
	var sessionLength = SessionReceiptItem()
	var hourlyRate = SessionReceiptItem()
	var tip = SessionReceiptItem()
	var total = SessionReceiptItem()
	
	let personalProgressView = PersonalProgressView()
	
	func configureCollectionViewCell() {
		addSubview(containerView)
		containerView.addSubview(title)
		containerView.addSubview(sessionSummaryContainer)
		containerView.addSubview(personalProgressView)
		sessionSummaryContainer.addSubview(subtitle)
		sessionSummaryContainer.addSubview(infoContainer)
		infoContainer.addSubview(partner)
		infoContainer.addSubview(userType)
		infoContainer.addSubview(subject)
		infoContainer.addSubview(sessionLength)
		infoContainer.addSubview(hourlyRate)
		infoContainer.addSubview(tip)
		infoContainer.addSubview(total)
	
		
		applyConstraints()
	}
	
	func applyConstraints() {
		containerView.snp.makeConstraints { (make) in
			make.top.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.95)
			make.height.equalToSuperview().multipliedBy(0.7)
		}
		title.snp.makeConstraints { (make) in
			make.top.centerX.width.equalToSuperview()
			make.height.equalTo(35)
		}
		sessionSummaryContainer.snp.makeConstraints { (make) in
			make.top.equalTo(title.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.7)
		}
		subtitle.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(5)
			make.left.equalToSuperview().inset(10)
			make.width.equalToSuperview()
			make.height.equalTo(35)
		}
		infoContainer.snp.makeConstraints { (make) in
			make.top.equalTo(subtitle.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		partner.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		personalProgressView.snp.makeConstraints { (make) in
			make.top.equalTo(sessionSummaryContainer.snp.bottom)
			make.width.bottom.centerX.equalToSuperview()
		}
		//Havent set up any contraints...
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		
		containerView.layer.cornerRadius = 8
	}
}
