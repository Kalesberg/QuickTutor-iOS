//
//  AddressTextField.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class AddressTextField: NoPasteTextField {
	override func configureTextField() {
		super.configureTextField()
		
		font = Fonts.createSize(15)
		textColor = Colors.grayText
		autocapitalizationType = .words
		layer.cornerRadius = 6
		layer.borderWidth = 1
		layer.borderColor = Colors.learnerPurple.cgColor
	}
	
	let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: padding)
	}
	
	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: padding)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: padding)
	}
}
