//
//  LearnerFiltersLocationCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 8/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LearnerFiltersLocationCell : UITableViewCell {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	let title : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .left
		label.text = "Location"
		label.font = Fonts.createBoldSize(16)
		
		return label
	}()
	
	let locationEnabledLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = Colors.grayText
		label.textAlignment = .right
		label.text = ""
		label.font = Fonts.createSize(13)
		
		return label
	}()
	
	let locationLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .left
		label.text = "276 Nairn Circle, Highland MI"
		label.font = Fonts.createSize(15)
		
		return label
	}()
	
	func configureTableViewCell() {
		addSubview(title)
		addSubview(locationEnabledLabel)
		addSubview(locationLabel)
		
		let cellBackground = UIView()
		cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		selectedBackgroundView = cellBackground
		
		backgroundColor = Colors.backgroundDark
		accessoryType = .disclosureIndicator

		applyConstraints()
	}
	func applyConstraints() {
		title.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview().inset(5)
			make.width.equalToSuperview().multipliedBy(0.4)
			make.height.equalTo(30)
		}
		locationLabel.snp.makeConstraints { (make) in
			make.top.equalTo(title.snp.bottom)
			make.left.equalToSuperview().inset(5)
			make.width.equalToSuperview()
			make.height.equalTo(30)
		}
		locationEnabledLabel.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.left.equalTo(title.snp.right)
			make.right.equalToSuperview()
			make.height.equalTo(20)
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}
