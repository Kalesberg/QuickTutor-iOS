//
//  AddSubjectTableViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class AddSubjectsTableViewCell : UITableViewCell  {
	
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
	
	let selectedIcon = SelectedCellIcon()
	
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
		addSubview(selectedIcon)
		
		selectedIcon.isSelected = false
		
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
		selectedIcon.snp.makeConstraints { (make) in
			make.left.equalTo(globalTutors.snp.right)
			make.right.equalToSuperview()
			make.centerY.equalToSuperview()
			make.height.equalToSuperview()
		}
	}
}

//this will be the icon we get from busman, for now i just copied your CheckBox functionality.
class SelectedCellIcon : BaseView, Interactable {
	
	var checkbox = UIImageView()
	
	let selectedImage = UIImage(named: "registration-checkbox-selected")! as UIImage
	let unselectedImage = UIImage(named: "registration-checkbox-unselected")! as UIImage
	
	var isSelected : Bool = false {
		didSet {
			checkbox.image = isSelected ? selectedImage : unselectedImage
		}
	}
	
	override func configureView() {
		addSubview(checkbox)
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		checkbox.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
}
