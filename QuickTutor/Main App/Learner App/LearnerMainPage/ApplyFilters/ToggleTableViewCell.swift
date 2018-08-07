//
//  ToggleTableViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 8/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class ToggleTableViewCell : BaseTableViewCell {
	
	let label : UILabel = {
		let label = UILabel()
		
		label.text = "Search Tutors Online (Video Call)"
		label.textColor = .white
		label.font = Fonts.createBoldSize(15)
		
		return label
	}()
	
	let toggle : UISwitch = {
		let toggle = UISwitch()
		
		toggle.onTintColor = Colors.learnerPurple
		
		return toggle
	}()
	
	override func configureView() {
		addSubview(label)
		addSubview(toggle)
		super.configureView()
		
		selectionStyle = .none
		backgroundColor = .clear
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.height.equalTo(30)
			make.top.equalToSuperview()
		}
		
		toggle.snp.makeConstraints { (make) in
			make.top.equalTo(label.snp.bottom).inset(-5)
			make.left.equalToSuperview()
			make.height.equalTo(55)
		}
	}
}
