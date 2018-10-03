//
//  MyProfileHeader.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class LearnerMyProfileHeader : UIView {
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
	
	let rating : UILabel = {
		let label = UILabel()
		label.textColor = Colors.gold
		label.font = Fonts.createBoldSize(14)
		label.textAlignment = .right
		return label
	}()
	
	private func configureView() {
		addSubview(profileImageViewButton)
		addSubview(nameContainer)
		nameContainer.addSubview(nameLabel)
		addSubview(rating)
		
		profileImageViewButton.addTarget(self, action: #selector(profileImageViewPressed), for: .touchUpInside)
		backgroundColor = Colors.navBarColor
		
		applyConstraints()
	}
	
	private func applyConstraints() {
		profileImageViewButton.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(20)
			make.height.equalToSuperview().multipliedBy(0.7)
			make.width.equalTo(profileImageViewButton.snp.height)
			make.centerX.equalToSuperview()
		}
		nameContainer.snp.makeConstraints { (make) in
			make.top.equalTo(profileImageViewButton.snp.bottom)
			make.centerX.width.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		nameLabel.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalToSuperview().multipliedBy(0.8)
		}
		rating.snp.makeConstraints { (make) in
			make.top.equalTo(profileImageViewButton.snp.top)
			make.right.equalToSuperview().inset(10)
			make.left.equalTo(profileImageViewButton.snp.right)
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
