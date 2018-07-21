//
//  SessionRequestCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/16/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SessionRequestConversationCell : UICollectionViewCell {
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureCollectionViewCell()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	let header = UIView()

	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Request Session"
		label.font = Fonts.createBoldSize(22)
		label.textAlignment = .center
		label.textColor = .white
		label.backgroundColor = Colors.learnerPurple
		
		return label
	}()
	
	let body = UIView()
	
	let subjectLabel : UILabel = {
		let label = UILabel()
		label.text = "Guitar Lessons"

		label.font = Fonts.createBoldSize(14)
		label.textAlignment = .center
		label.textColor = .white
		return label
	}()
	let dateLabel : UILabel = {
		let label = UILabel()
		label.text = "Thu, Apr 18"

		label.font = Fonts.createSize(14)
		label.textAlignment = .center
		label.textColor = .white
		return label
	}()
	let timeLabel : UILabel = {
		let label = UILabel()
		label.text = "6:00pm - 8:00pm"

		label.font = Fonts.createSize(14)
		label.textAlignment = .center
		label.textColor = .white
		return label
	}()
	let priceLabel : UILabel = {
		let label = UILabel()
		label.text = "$18.00"
		label.font = Fonts.createSize(14)
		label.textAlignment = .center
		label.textColor = .white
		label.backgroundColor = Colors.green
		return label
	}()
	
	let footer : UIView = {
		let view = UIView()
		
		view.backgroundColor = Colors.backgroundDark
		
		return view
	}()
	
	func configureCollectionViewCell() {
		addSubview(header)
		header.addSubview(title)
		addSubview(body)
		body.addSubview(subjectLabel)
		body.addSubview(dateLabel)
		body.addSubview(timeLabel)
		body.addSubview(priceLabel)
		addSubview(footer)
		
		backgroundColor = Colors.learnerPurple
		
		applyConstraints()
	}
	func applyConstraints() {
		header.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.2)
		}
		title.snp.makeConstraints { (make) in
			make.center.width.height.equalToSuperview()
		}
		body.snp.makeConstraints { (make) in
			make.top.equalTo(header.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.55)
		}
		dateLabel.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.left.equalToSuperview().inset(10)
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalTo(20)
		}
		subjectLabel.snp.makeConstraints { (make) in
			make.bottom.equalTo(dateLabel.snp.top)
			make.left.equalToSuperview().inset(10)
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalTo(20)
		}
		timeLabel.snp.makeConstraints { (make) in
			make.top.equalTo(dateLabel.snp.bottom)
			make.left.equalToSuperview().inset(10)
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalTo(20)
		}
		priceLabel.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.right.equalToSuperview().inset(10)
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalTo(30)
		}
		footer.snp.makeConstraints { (make) in
			make.top.equalTo(body.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.bottom.equalToSuperview()
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		priceLabel.layer.cornerRadius = priceLabel.frame.height / 2
		
	}
}
