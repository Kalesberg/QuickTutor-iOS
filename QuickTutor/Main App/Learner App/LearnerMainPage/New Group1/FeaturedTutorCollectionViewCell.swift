//
//  FeaturedCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class FeaturedTutorCollectionViewCell : UICollectionViewCell {
	
	let featuredTutor = FeaturedTutorView()
	
	let price : UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.textColor = .white
		label.text = "$45/hr"
		label.font = Fonts.createSize(14)
		label.adjustsFontSizeToFitWidth = true
		//label.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.7, offset: CGSize(width:2,height:2), radius: 5)
		label.backgroundColor = Colors.learnerPurple
		return label
	}()
	
	let background : UIView = {
		let view = UIView()
		
		view.backgroundColor = Colors.registrationDark
		//view.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.7, offset: CGSize(width: 2, height: 2), radius: 5)
		
		return view
	}()
	
	required override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	func configureView() {
		addSubview(background)
		background.addSubview(featuredTutor)
		addSubview(price)

		featuredTutor.backgroundColor = .clear
		applyConstraints()
	}
	func applyConstraints(){
		background.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview().inset(10)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalToSuperview().multipliedBy(0.9)
			make.centerX.equalToSuperview()
		}
		featuredTutor.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalToSuperview()
		}
		price.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(-10)
			make.left.equalToSuperview().inset(-10)
			make.width.equalTo(50)
			make.height.equalTo(20)
		}
		layoutIfNeeded()
		price.layer.cornerRadius = 10
	}
}

