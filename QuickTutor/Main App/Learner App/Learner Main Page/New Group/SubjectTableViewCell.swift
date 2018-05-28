//
//  SubjectTableViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


class SubjectTableViewCell : UITableViewCell  {
	
	let subject : UILabel = {
		
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .left
		label.numberOfLines = 2
		label.font = Fonts.createSize(18)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let localTutors : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .left
		label.text = "1002 Local Tutors"
		label.font = Fonts.createSize(14)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let globalTutors : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.text = "2410 Global Tutors"
		label.textAlignment = .left
		label.font = Fonts.createSize(14)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let averagePrice : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.text = "AVG/PRICE"
		label.font = Fonts.createSize(13)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let price : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.text = "15/hr"
		label.font = Fonts.createSize(16)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configureTableViewCell() {
		addSubview(subject)
		addSubview(localTutors)
		addSubview(globalTutors)
		addSubview(price)
		addSubview(averagePrice)
		
		let cellBackground = UIView()
		cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		selectedBackgroundView = cellBackground
		
		backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		
		applyConstraints()
	}
	
	func applyConstraints() {
		subject.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		localTutors.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalTo(subject.snp.right)
			make.width.equalToSuperview().multipliedBy(0.25)
			make.height.equalToSuperview().multipliedBy(0.5)
		}
		globalTutors.snp.makeConstraints { (make) in
			make.top.equalTo(localTutors.snp.bottom)
			make.left.equalTo(localTutors.snp.left)
			make.width.equalToSuperview().multipliedBy(0.25)
			make.height.equalToSuperview().multipliedBy(0.5)
		}
		averagePrice.snp.makeConstraints { (make) in
			make.left.equalTo(localTutors.snp.right)
			make.bottom.equalTo(localTutors.snp.bottom)
			make.width.equalToSuperview().multipliedBy(0.2)
			make.height.equalToSuperview().multipliedBy(0.3)
		}
		price.snp.makeConstraints { (make) in
			make.left.equalTo(averagePrice.snp.left)
			make.top.equalTo(averagePrice.snp.bottom)
			make.width.equalToSuperview().multipliedBy(0.2)
			make.height.equalToSuperview().multipliedBy(0.3)
		}
	}
}
