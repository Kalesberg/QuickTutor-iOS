//
//  SeeAllButton.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class SeeAllButton: InteractableView, Interactable {
	var label = UILabel()
	
	override func configureView() {
		addSubview(label)
		super.configureView()
		
		layer.cornerRadius = 7
		layer.borderWidth = 1
		layer.borderColor = Colors.grayText.cgColor
		label.text = "See All »"
		label.textColor = Colors.grayText
		label.font = Fonts.createSize(16)
		label.textAlignment = .center
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}
	
	func touchStart() {
		alpha = 0.7
	}
	
	func didDragOff() {
		alpha = 1.0
	}
}
