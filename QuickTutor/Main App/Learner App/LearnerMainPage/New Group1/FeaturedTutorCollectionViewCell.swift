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
	let view : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.learnerPurple
		view.layer.cornerRadius = 10
		//view.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.7, offset: CGSize(width:2,height:2), radius: 5)
		return view
	}()
	let price : UILabel = {
		let label = UILabel()
		
		label.textAlignment = .center
		label.textColor = .white
		label.text = "$45/hr"
		label.font = Fonts.createSize(13)
		label.adjustsFontSizeToFitWidth = true
		label.backgroundColor = .clear
		
		return label
	}()
	
	let background : UIView = {
		let view = UIView()
		
		view.backgroundColor = Colors.registrationDark
		view.layer.cornerRadius = 8
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
		addSubview(view)
		view.addSubview(price)
		
		featuredTutor.backgroundColor = .clear
		//backgroundColor = .yellow
		applyConstraints()
	}
	func applyConstraints(){
		background.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.equalToSuperview()
			make.center.equalToSuperview()
		}
		featuredTutor.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.center.equalToSuperview()
			make.height.equalToSuperview()
		}
		view.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(-10)
			make.left.equalToSuperview().inset(-5)
			make.width.equalTo(60)
			make.height.equalTo(20)
		}
		price.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
}

