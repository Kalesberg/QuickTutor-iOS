//
//  SignInView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class SignInView: RegistrationGradientView, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	
	var backButton = RegistrationBackButton()
	var nextButton = RegistrationNextButton()
	
	var phoneNumberTextField = RegistrationTextField()
	
	// var facebookButton       = FBSDKLoginButton()
	var signinLabel = UILabel()
	
	var quicktutorText = UIImageView()
	var learnAnythingLabel = CenterTextLabel()
	var quicktutorFlame = UIImageView()
	
	var numberLabel = LeftTextLabel()
	
	var container = UIView()
	var phoneTextField = PhoneTextField()
	// var facebookButton2 = FacebookButton()
	
	var infoLabel = UILabel()
	
	override func configureView() {
		addKeyboardView()
		addSubview(backButton)
		addSubview(quicktutorText)
		addSubview(learnAnythingLabel)
		addSubview(quicktutorFlame)
		addSubview(infoLabel)
		addSubview(container)
		container.addSubview(phoneTextField)
		phoneTextField.addSubview(numberLabel)
		// container.addSubview(facebookButton2)
		addSubview(nextButton)
		super.configureView()
		insertSubview(nextButton, aboveSubview: container)
		
		backButton.alpha = 0.0
		backButton.isUserInteractionEnabled = false
		
		nextButton.alpha = 0.0
		nextButton.isUserInteractionEnabled = false
		
		quicktutorText.image = UIImage(named: "quicktutor-text")
		
		learnAnythingLabel.label.text = "Learn Anything. Teach Anyone."
		learnAnythingLabel.label.font = Fonts.createLightSize(20)
		
		let formattedString = NSMutableAttributedString()
		formattedString
			.regular("By tapping continue or entering a mobile phone number, I agree to QuickTutor's Service Terms of Use, Privacy Policy, Payments Terms of Service, and Nondiscrimination Policy.\n", 13, .white)
			.bold("Patent Pending.", 15, Colors.grayText)
		
		infoLabel.attributedText = formattedString
		infoLabel.numberOfLines = 0
		
		quicktutorFlame.image = UIImage(named: "qt-flame")
		
		numberLabel.label.text = "YOUR MOBILE NUMBER"
		numberLabel.label.font = Fonts.createBoldSize(14)
		
		phoneTextField.textField.keyboardType = .numberPad
		
		//		phoneNumberTextField.textField.keyboardType = .numberPad
		//
		//		facebookButton.setTitle("Log in with facebook", for: .normal)
		//		signinLabel.text = "Sign in Screen..."
		//		facebookButton.backgroundColor = UIColor.blue
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		backButton.snp.makeConstraints { make in
			if #available(iOS 11.0, *) {
				make.top.equalTo(safeAreaLayoutGuide.snp.top)
			} else {
				make.top.equalToSuperview().inset(DeviceInfo.statusbarHeight)
			}
			make.width.equalToSuperview().multipliedBy(0.25)
			make.height.equalToSuperview().multipliedBy(0.13)
			make.left.equalToSuperview()
		}
		
		nextButton.snp.makeConstraints { make in
			make.bottom.equalTo(keyboardView.snp.top)
			make.right.equalToSuperview().inset(15)
			make.width.equalToSuperview().multipliedBy(0.25)
			make.height.equalToSuperview().multipliedBy(0.1)
		}
		
		quicktutorText.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(15)
			} else {
				make.top.equalTo(backButton).inset(15)
			}
		}
		
		learnAnythingLabel.snp.makeConstraints { make in
			make.top.equalTo(quicktutorText.snp.bottom)
			make.height.equalTo(30)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
		
		quicktutorFlame.snp.makeConstraints { make in
			make.top.equalTo(learnAnythingLabel.snp.bottom).offset(30)
			make.centerX.equalToSuperview()
		}
		
		infoLabel.snp.makeConstraints { make in
			if UIScreen.main.bounds.height == 480 {
				make.width.equalToSuperview().multipliedBy(0.85)
				make.centerX.bottom.equalToSuperview()
			} else {
				make.width.equalToSuperview().multipliedBy(0.85)
				if #available(iOS 11.0, *) {
					make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(15)
				} else {
					make.bottom.equalToSuperview().inset(15)
				}
				make.centerX.equalToSuperview()
			}
		}
		
		container.snp.makeConstraints { make in
			make.top.equalTo(quicktutorFlame.snp.bottom)
			make.bottom.equalTo(infoLabel.snp.top)
			make.width.equalToSuperview().multipliedBy(0.85)
			make.centerX.equalToSuperview()
		}
		
		phoneTextField.snp.makeConstraints { make in
			make.width.equalToSuperview()
			make.centerY.equalToSuperview()
			make.height.equalTo(60)
			make.centerX.equalToSuperview()
		}
		
		numberLabel.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		
		//		facebookButton2.snp.makeConstraints { (make) in
		//			make.centerY.equalToSuperview().multipliedBy(1.5)
		//			make.height.equalTo(30)
		//			make.width.equalToSuperview()
		//			make.centerX.equalToSuperview()
		//		}
	}
}
