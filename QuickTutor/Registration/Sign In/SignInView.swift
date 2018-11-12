//
//  SignInView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class SignInView: BaseLayoutView, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	let backButton = RegistrationBackButton()
	let nextButton = RegistrationNextButton()
	
	var phoneNumberTextField = RegistrationTextField()
	var signinLabel = UILabel()
	
	let quicktutorText : UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "quicktutor-text")
		return imageView
	}()
	
	let learnAnythingLabel : CenterTextLabel = {
		let centerTextLabel = CenterTextLabel()
		centerTextLabel.label.text = "Learn Anything. Teach Anyone.™"
		centerTextLabel.label.font = Fonts.createLightSize(20)
		return centerTextLabel
	}()
	
	var quicktutorFlame : UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "qt-flame")
		return imageView
	}()
	
	let numberLabel : LeftTextLabel = {
		let leftTextLabel = LeftTextLabel()
		leftTextLabel.label.text = "YOUR MOBILE NUMBER"
		leftTextLabel.label.font = Fonts.createBoldSize(14)
		return leftTextLabel
	}()
	
	var container = UIView()
	
	let phoneTextField : PhoneTextFieldView = {
		let view = PhoneTextFieldView()
		view.textField.keyboardType = .numberPad
		return view
	}()
	
	let infoLabel : UILabel = {
		let label = UILabel()
		label.attributedText = NSMutableAttributedString()
			.regular("By tapping continue or entering a mobile phone number, I agree to QuickTutor's Service Terms of Use, Privacy Policy, Payments Terms of Service, and Nondiscrimination Policy.\n", 13, .white)
			.bold("U.S. Patent Pending.", 15, Colors.grayText)
		label.numberOfLines = 0
		return label
	}()
	
    let facebookButton: FacebookButton = {
        let button = FacebookButton()
        return button
    }()
    
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
		addSubview(nextButton)
        addSubview(facebookButton)
		super.configureView()
		insertSubview(nextButton, aboveSubview: container)
		
		backButton.alpha = 0.0
		backButton.isUserInteractionEnabled = false
		
		nextButton.alpha = 0.0
		nextButton.isUserInteractionEnabled = false
	
		applyGradient(firstColor: (Colors.oldTutorBlue.cgColor), secondColor: (Colors.oldLearnerPurple.cgColor), angle: 160, frame: frame)

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
        
        facebookButton.snp.makeConstraints { (make) in
            make.top.equalTo(phoneTextField.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(phoneTextField.snp.width)
            make.height.equalTo(47).priority(1000)
        }
	}
}
