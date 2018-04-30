//
//  Birthday.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/19/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit

class BirthdayView: RegistrationNavBarView {
	
	var birthdayPicker    = RegistrationDatePicker()
	
	var contentView       = UIView()
	var birthdayLabel     = RegistrationTextField()
	var birthdayInfoBig   = LeftTextLabel()
	var birthdayInfoSmall = LeftTextLabel()
	
	let errorLabel : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createItalicSize(17)
		label.textColor = .red
		label.isHidden = true
		label.numberOfLines = 2
		
		return label
	}()
	
	override func configureView() {
		super.configureView()
		
        progressBar.progress = 0.8
        progressBar.applyConstraints()
		
		addSubview(birthdayPicker)
		addSubview(contentView)
		
		contentView.addSubview(birthdayLabel)
		contentView.addSubview(birthdayInfoBig)
		contentView.addSubview(birthdayInfoSmall)
		contentView.addSubview(errorLabel)
		
		titleLabel.label.text = "We need your birthday"
		titleLabel.label.adjustsFontSizeToFitWidth = true
		titleLabel.label.adjustsFontForContentSizeCategory = true
		errorLabel.text = "Must be 18 years or older to use QuickTutor"
		
		birthdayLabel.textField.font = Fonts.createSize(CGFloat(DeviceInfo.textFieldFontSize))
		birthdayLabel.placeholder.text = "BIRTHDATE"
		birthdayLabel.isUserInteractionEnabled = false
		
		let date = Date()
		
		birthdayPicker.datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: date)
		birthdayPicker.datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -90, to: date)
		
		birthdayInfoBig.label.font = Fonts.createSize(18)
		birthdayInfoBig.label.text = "Others will not be able to see your birthday"
		birthdayInfoBig.label.numberOfLines = 2
        birthdayInfoBig.label.adjustsFontSizeToFitWidth = true
		
		birthdayInfoSmall.label.font = Fonts.createLightSize(14.5)
		
		birthdayInfoSmall.label.text = "By entering my birthday, I agree that I'm at least 18 years old."
		birthdayInfoSmall.label.numberOfLines = 2
        birthdayInfoSmall.label.adjustsFontSizeToFitWidth = true
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		birthdayPicker.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalTo(DeviceInfo.keyboardHeight)
		}
		
		nextButton.snp.makeConstraints { (make) in
			make.bottom.equalTo(birthdayPicker.snp.top)
			make.right.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.25)
			make.height.equalToSuperview().multipliedBy(0.1)
		}
		
		contentView.snp.makeConstraints { (make) in
			make.top.equalTo(titleLabel.snp.bottom)
			make.bottom.equalTo(nextButton.snp.top)
			make.left.equalTo(titleLabel)
			make.right.equalTo(titleLabel)
		}
		
		birthdayLabel.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.5)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
		
		birthdayInfoBig.snp.makeConstraints { (make) in
			make.top.equalTo(birthdayLabel.snp.bottom)
			make.height.equalToSuperview().multipliedBy(0.31)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
		
		birthdayInfoSmall.snp.makeConstraints { (make) in
			make.top.equalTo(birthdayInfoBig.snp.bottom)
			make.height.equalToSuperview().multipliedBy(0.25)
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
		
		errorLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.centerY.equalTo(nextButton).inset(4)
			make.right.equalTo(nextButton.snp.left).inset(20)
		}
	}
}

class Birthday: BaseViewController {
	
	let date = Date()
	let dateformatter = DateFormatter()
	let calendar = Calendar.current
	
	override var contentView: BirthdayView {
		return view as! BirthdayView
	}
	
	override func loadView() {
		view = BirthdayView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		dateformatter.dateFormat = "MMMM d'\(daySuffix(date: date))' yyyy"
		let today = dateformatter.string(from: date)
		contentView.birthdayLabel.textField.text = today
		contentView.birthdayPicker.datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	private func getAgeBirthday() -> Int {
		let birthdate = contentView.birthdayPicker.datePicker.calendar!
		let birthday = birthdate.dateComponents([.day, .month, .year], from: contentView.birthdayPicker.datePicker.date)
		let age = birthdate.dateComponents([.year], from: contentView.birthdayPicker.datePicker.date, to: date)
		
		if age.year! > 0 {
			//need more checks here...
			Registration.age = age.year!
			Registration.dob = String("\(birthday.day!)/\(birthday.month!)/\(birthday.year!)")
			contentView.errorLabel.isHidden = true
		}
		return age.year!
	}
	override func handleNavigation() {
		if (touchStartView == contentView.backButton) {
			navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
			navigationController!.popViewController(animated: false)
		} else if(touchStartView == contentView.nextButton) {
			
			let next = UploadImage()
			if getAgeBirthday() >= 18 {
				navigationController!.pushViewController(next, animated: true)
			} else {
				contentView.errorLabel.isHidden = false
			}
		}
	}
	
	private func daySuffix(date: Date) -> String {
		let calendar = Calendar.current
		let dayOfMonth = calendar.component(.day, from: date)
		switch dayOfMonth {
		case 1, 21, 31:
			return "st"
		case 2, 22:
			return "nd"
		case 3, 23:
			return "rd"
		default:
			return "th"
		}
	}
	
	@objc
	private func datePickerValueChanged (_ sender: UIDatePicker) {
		//show new date on label when its changed.
		dateformatter.dateFormat = "MMMM d'\(daySuffix(date: contentView.birthdayPicker.datePicker.date))' yyyy"
		let date = dateformatter.string(from: contentView.birthdayPicker.datePicker.date)
		contentView.birthdayLabel.textField.text! = date
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
