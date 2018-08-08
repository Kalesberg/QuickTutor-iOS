//
//  YourListingBackGroundView.swift
//  QuickTutor
//
//  Created by QuickTutor on 8/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class NoListingBackgroundView : BaseView {
	
	let noListingsImageView : UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "sad-face")
		return imageView
	}()
	
	let noListingsTitle : UILabel = {
		let label = UILabel()
		
		label.text = "No Active Listing"
		label.font = Fonts.createSize(18)
		label.textColor = UIColor.white.withAlphaComponent(0.9)
		label.adjustsFontSizeToFitWidth = true
		label.textAlignment = .center
		
		return label
	}()
	
	let noListingsSubtitle : UILabel = {
		let label = UILabel()
		
		label.text = "When you create a listing you will see it here."
		label.font = Fonts.createLightSize(16)
		label.textColor = UIColor.white.withAlphaComponent(0.8)
		label.adjustsFontSizeToFitWidth = true
		label.textAlignment = .center
		
		return label
	}()
	
	let createListing : UIButton = {
		let button = UIButton(frame: .zero)
		
		button.setTitle("Create a Listing!", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = Fonts.createBoldSize(20)
		button.layer.borderColor = UIColor.white.cgColor
		button.layer.borderWidth = 1
		button.addTarget(self, action: #selector(createAListing(_:)), for: .touchUpInside)
		
		return button
	}()
	
	var delegate : CreateListing?
	
	override func configureView() {
		addSubview(createListing)
		addSubview(noListingsTitle)
		addSubview(noListingsSubtitle)
		addSubview(noListingsImageView)
		super.configureView()
		
		isUserInteractionEnabled = true
		applyConstraints()
	}
	override func applyConstraints() {
		noListingsImageView.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(20)
			make.width.height.equalTo(90)
			make.centerX.equalToSuperview()
		}
		noListingsTitle.snp.makeConstraints { (make) in
			make.top.equalTo(noListingsImageView.snp.bottom).inset(-10)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(25)
		}
		noListingsSubtitle.snp.makeConstraints { (make) in
			make.top.equalTo(noListingsTitle.snp.bottom)
			make.centerX.width.equalToSuperview()
			make.height.equalTo(25)
		}
		createListing.snp.makeConstraints { (make) in
			make.top.equalTo(noListingsSubtitle.snp.bottom).inset(-10)
			make.centerX.equalToSuperview()
			make.width.equalTo(225)
			make.height.equalTo(40)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		createListing.layer.cornerRadius = createListing.frame.height / 4
	}
	
	@objc func createAListing(_ sender: Any) {
		delegate?.createListingButtonPressed()
	}
}
