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
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
		label.font = Fonts.createSize(16)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let subcategory : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createSize(14)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
    let subcategoryContainer : UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.tutorBlue
        view.layer.cornerRadius = 8
        
        return view
    }()
	let cellBackground = UIView()
	
    func configureTableViewCell() {
		addSubview(subject)
        addSubview(subcategoryContainer)
        subcategoryContainer.addSubview(subcategory)
		
		cellBackground.backgroundColor = UIColor.black
		selectedBackgroundView = cellBackground
		
		backgroundColor = .clear
		
		applyConstraints()
	}
	
	func applyConstraints() {
		subcategoryContainer.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.6)
            make.right.equalToSuperview().inset(10)
            make.width.equalTo(140)
		}
        
        subcategory.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(4)
            make.center.equalToSuperview()
        }
        
        subject.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(subcategoryContainer.snp.left).inset(-5)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		subcategory.layer.masksToBounds = true
	}
}
