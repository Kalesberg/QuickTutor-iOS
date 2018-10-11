//
//  TutorMyProfileHeader.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//


import Foundation
import UIKit
import SnapKit

class TutorMyProfileHeader : UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}
	
	var parentViewController : UIViewController?
	var imageCount : Int = 0
	var userId : String = ""
	
	let profileImageViewButton : UIButton = {
		let button = UIButton()
		button.imageView?.scaleImage()
		button.imageView?.clipsToBounds = true
		return button
	}()
	
	let nameContainer = UIView()
	
	let nameLabel : UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createBoldSize(20)
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	let rateReviewContainer = UIView()
	
	let price : UILabel = {
		let label = UILabel()
		
		label.backgroundColor = Colors.green
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createBoldSize(14)
		label.layer.masksToBounds = true
		label.layer.cornerRadius = 10
		
		return label
	}()
	
	let rating : UILabel = {
		let label = UILabel()
		
		label.textColor = Colors.gold
		label.textAlignment = .center
		label.font = Fonts.createSize(14)
		
		return label
	}()
	
	private func configureView() {
		addSubview(profileImageViewButton)
		addSubview(nameContainer)
		nameContainer.addSubview(nameLabel)
		addSubview(rateReviewContainer)
		rateReviewContainer.addSubview(price)
		rateReviewContainer.addSubview(rating)
		
		profileImageViewButton.addTarget(self, action: #selector(profileImageViewPressed), for: .touchUpInside)
		backgroundColor = Colors.navBarColor
		
		applyConstraints()
	}
	
	private func applyConstraints() {
		profileImageViewButton.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(20)
			make.height.width.equalTo(175)
			make.centerX.equalToSuperview()
		}
		nameContainer.snp.makeConstraints { (make) in
			make.top.equalTo(profileImageViewButton.snp.bottom)
			make.centerX.width.equalToSuperview()
		}
		nameLabel.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalToSuperview().multipliedBy(0.8)
		}
		rateReviewContainer.snp.makeConstraints { (make) in
			make.top.equalTo(nameContainer.snp.bottom)
			make.centerX.bottom.equalToSuperview()
			make.width.equalToSuperview()
		}
		price.snp.makeConstraints { (make) in
			make.right.equalTo(rateReviewContainer.snp.centerX).inset(-10)
			make.top.equalToSuperview()
			make.height.equalTo(20)
			make.width.equalTo(80)
		}
		rating.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalTo(rateReviewContainer.snp.centerX).inset(10)
			make.height.equalTo(20)
		}
	}
	
	@objc func profileImageViewPressed(_ sender: UIButton) {
		parentViewController?.displayProfileImageViewer(imageCount: imageCount, userId: userId)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		profileImageViewButton.roundCorners(.allCorners, radius: 8)
	}
}
