//
//  EditBillingAddressView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class EditBillingAddressView: MainLayoutTitleBackSaveButton {
	
	var contentView = UIView()
	
	let addressLine1Title = SectionTitle()
	let addressLine1TextField = AddressTextField()
	
	let cityTitle = SectionTitle()
	let cityTextField = AddressTextField()
	
	let stateTitle = SectionTitle()
	let stateTextField = AddressTextField()
	
	let zipTitle = SectionTitle()
	let zipTextField = AddressTextField()
	
	override func configureView() {
		addSubview(contentView)
		contentView.addSubview(addressLine1Title)
		contentView.addSubview(addressLine1TextField)
		contentView.addSubview(cityTitle)
		contentView.addSubview(cityTextField)
		contentView.addSubview(stateTitle)
		contentView.addSubview(stateTextField)
		contentView.addSubview(zipTitle)
		contentView.addSubview(zipTextField)
		
		super.configureView()
		
		title.label.text = "Billing Address"
		
		addressLine1Title.label.text = "Address"
		cityTitle.label.text = "City"
		stateTitle.label.text = "State"
		zipTitle.label.text = "Postal Code"
		
		addressLine1TextField.attributedPlaceholder = NSAttributedString(string: "Enter Billing Address", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
		addressLine1TextField.keyboardType = .asciiCapable
		
		cityTextField.attributedPlaceholder = NSAttributedString(string: "Enter City", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
		cityTextField.keyboardType = .asciiCapable
		
		stateTextField.attributedPlaceholder = NSAttributedString(string: "Enter State", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
		stateTextField.keyboardType = .asciiCapable
		stateTextField.autocapitalizationType = .allCharacters
		
		zipTextField.attributedPlaceholder = NSAttributedString(string: "Enter Postal Code", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
		zipTextField.keyboardType = .decimalPad
		
		navbar.backgroundColor = Colors.tutorBlue
		statusbarView.backgroundColor = Colors.tutorBlue
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		contentView.snp.makeConstraints { make in
			make.width.equalToSuperview().multipliedBy(0.85)
			make.top.equalTo(navbar.snp.bottom)
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.5)
		}
		
		addressLine1Title.snp.makeConstraints { make in
			make.top.equalTo(navbar.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(35)
		}
		
		addressLine1TextField.snp.makeConstraints { make in
			make.top.equalTo(addressLine1Title.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		
		cityTitle.snp.makeConstraints { make in
			make.top.equalTo(addressLine1TextField.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(35)
		}
		
		cityTextField.snp.makeConstraints { make in
			make.top.equalTo(cityTitle.snp.bottom)
			make.width.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		
		stateTitle.snp.makeConstraints { make in
			make.width.equalToSuperview().dividedBy(2)
			make.top.equalTo(cityTextField.snp.bottom)
			make.left.equalTo(cityTitle.snp.left)
			make.height.equalTo(35)
		}
		
		stateTextField.snp.makeConstraints { make in
			make.top.equalTo(stateTitle.snp.bottom)
			make.width.equalToSuperview().dividedBy(2)
			make.left.equalTo(cityTextField.snp.left)
			make.height.equalTo(30)
		}
		zipTitle.snp.makeConstraints { make in
			make.width.equalToSuperview().dividedBy(2)
			make.top.equalTo(cityTextField.snp.bottom)
			make.right.equalTo(cityTitle.snp.right)
			make.height.equalTo(35)
		}
		
		zipTextField.snp.makeConstraints { make in
			make.top.equalTo(zipTitle.snp.bottom)
			make.width.equalToSuperview().dividedBy(2)
			make.right.equalTo(cityTextField.snp.right)
			make.height.equalTo(30)
		}
	}
}
