//
//  EditBirthdateView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class EditBirthdateView: MainLayoutTitleBackSaveButton {
	
	let birthdayPicker = RegistrationDatePicker()
	let contentView = UIView()
	
	let birthdayLabel : RegistrationTextField = {
		let label = RegistrationTextField()
		
		label.textField.font = Fonts.createSize(CGFloat(DeviceInfo.textFieldFontSize))
		label.placeholder.text = "BIRTHDATE"
		label.isUserInteractionEnabled = false
		
		return label
	}()
	
	let birthdayInfoBig : LeftTextLabel = {
		let label = LeftTextLabel()
		label.label.font = Fonts.createSize(18)
		label.label.text = "Others will not be able to see your birthday"
		label.label.numberOfLines = 2
		label.label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let birthdayInfoSmall : LeftTextLabel = {
		let label = LeftTextLabel()
		label.label.font = Fonts.createLightSize(14.5)
		
		label.label.text = "By entering my birthday, I agree that I'm at least 18 years old."
		label.label.numberOfLines = 2
		label.label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let errorLabel: UILabel = {
		let label = UILabel()
		label.font = Fonts.createItalicSize(17)
		label.textColor = .red
		label.isHidden = true
		label.numberOfLines = 2
		label.text = "Must be 18 years or older to use QuickTutor"
		
		return label
	}()
	
	override func configureView() {
		addSubview(birthdayPicker)
		addSubview(contentView)
		contentView.addSubview(birthdayLabel)
		contentView.addSubview(birthdayInfoBig)
		contentView.addSubview(birthdayInfoSmall)
		contentView.addSubview(errorLabel)
		super.configureView()

		title.label.text = "Edit Birthdate"
		
		setupDatePicker()
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		birthdayPicker.snp.makeConstraints { make in
			make.bottom.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalTo(DeviceInfo.keyboardHeight)
		}
		contentView.snp.makeConstraints { make in
			make.top.equalTo(navbar.snp.bottom)
			make.bottom.equalTo(birthdayPicker.snp.top)
			make.left.equalToSuperview().inset(20)
			make.right.equalToSuperview().inset(20)
		}
		birthdayLabel.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.47)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
		birthdayInfoBig.snp.makeConstraints { make in
			make.top.equalTo(birthdayLabel.snp.bottom)
			make.height.equalTo(35)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
		birthdayInfoSmall.snp.makeConstraints { make in
			make.top.equalTo(birthdayInfoBig.snp.bottom)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
		errorLabel.snp.makeConstraints { make in
			make.width.centerX.equalToSuperview()
			make.height.equalTo(30)
			make.bottom.equalTo(birthdayPicker.snp.top).inset(-10)
		}
	}
	private func setupDatePicker() {
		let date = Date()
		birthdayPicker.datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: date)
		birthdayPicker.datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -113, to: date)
		birthdayPicker.datePicker.setDate(date, animated: true)
	}
}
