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
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let subject : UILabel = {
		
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .left
		label.numberOfLines = 2
		label.font = Fonts.createSize(17)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let subcategory : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createSize(13)
		
		return label
	}()
    
    let subcatContainer = UIView()
	let selectedIcon = SelectedCellIcon()
	let cellBackground = UIView()

	func configureTableViewCell() {
		addSubview(subject)
        addSubview(subcatContainer)
		subcatContainer.addSubview(subcategory)
		addSubview(selectedIcon)
		
		selectedIcon.isSelected = false
		selectedBackgroundView = cellBackground
		subcatContainer.layer.cornerRadius = 9
        subcatContainer.backgroundColor = Colors.tutorBlue
		backgroundColor = .clear
		
		applyConstraints()
	}
	
	func applyConstraints() {
        selectedIcon.snp.makeConstraints { (make) in
            make.width.equalTo(60)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        subject.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(20)
            make.right.equalTo(selectedIcon.snp.left)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
	}
	override func setSelected(_ selected: Bool, animated: Bool) {
		let color = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)

		super.setSelected(selected, animated: animated)
		
		if selected {
			cellBackground.backgroundColor = color
			subcategory.backgroundColor = Colors.tutorBlue
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		subcategory.layer.masksToBounds = true
		subcategory.layer.cornerRadius = 5
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
