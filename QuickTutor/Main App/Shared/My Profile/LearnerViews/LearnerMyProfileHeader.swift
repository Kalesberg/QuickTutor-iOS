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
	
	let profileImageView : UIImageView = {
		let imageView = UIImageView()
		imageView.scaleImage()
		imageView.clipsToBounds = true
		return imageView
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
	
	let buttonMask : UIButton = {
		let button = UIButton()
		button.backgroundColor = .clear
		return button
	}()
	
	private func configureView() {
		addSubview(profileImageView)
		addSubview(nameContainer)
		nameContainer.addSubview(nameLabel)
		addSubview(rating)
		addSubview(buttonMask)
		
		buttonMask.addTarget(self, action: #selector(profileImageViewPressed), for: .touchUpInside)
		backgroundColor = Colors.navBarColor
		
		applyConstraints()
	}
	
	private func applyConstraints() {
		profileImageView.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(20)
			make.height.width.equalTo(175)
			make.centerX.equalToSuperview()
		}
		buttonMask.snp.makeConstraints { (make) in
			make.edges.equalTo(profileImageView)
		}
		nameContainer.snp.makeConstraints { (make) in
			make.top.equalTo(profileImageView.snp.bottom)
			make.centerX.width.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		nameLabel.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalToSuperview().multipliedBy(0.8)
		}
		rating.snp.makeConstraints { (make) in
			make.top.equalTo(profileImageView.snp.top)
			make.right.equalToSuperview().inset(10)
			make.left.equalTo(profileImageView.snp.right)
			make.height.equalTo(20)
		}
	}
	
	@objc func profileImageViewPressed(_ sender: UIButton) {
		parentViewController?.displayProfileImageViewer(imageCount: imageCount, userId: userId)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		profileImageView.roundCorners(.allCorners, radius: 8)
	}
}
