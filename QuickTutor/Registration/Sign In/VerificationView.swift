//
//  VerificationView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class VerificationView: RegistrationNavBarKeyboardView {
	
	var vcDigit1         = RegistrationDigitTextField()
	var vcDigit2         = RegistrationDigitTextField()
	var vcDigit3         = RegistrationDigitTextField()
	var vcDigit4         = RegistrationDigitTextField()
	var vcDigit5         = RegistrationDigitTextField()
	var vcDigit6         = RegistrationDigitTextField()
	
	var digitView        = UIView()
	var leftDigits       = UIView()
	var rightDigits      = UIView()
	
	var resendButtonView = UIView()
	
	let resendVCButton : UIButton = {
		let button = UIButton()
		
		button.titleLabel?.textColor = .white
		button.titleLabel?.font = Fonts.createSize(18)
		button.setTitle("Resend verification code »", for: .normal)
		
		return button
	}()
	
	override func configureView() {
		super.configureView()
		leftDigits.addSubview(vcDigit1)
		leftDigits.addSubview(vcDigit2)
		leftDigits.addSubview(vcDigit3)
		rightDigits.addSubview(vcDigit4)
		rightDigits.addSubview(vcDigit5)
		rightDigits.addSubview(vcDigit6)
		
		contentView.addSubview(digitView)
		digitView.addSubview(leftDigits)
		digitView.addSubview(rightDigits)
		
		contentView.addSubview(resendButtonView)
		resendButtonView.addSubview(resendVCButton)
		
		progressBar.progress = 1
		progressBar.applyConstraints()
		progressBar.divider.isHidden = true
		
		titleLabel.label.text = "Enter the 6-digit code we've sent to: \(Registration.phone.formatPhoneNumber())"
		
		titleLabel.label.adjustsFontSizeToFitWidth = true
		titleLabel.label.adjustsFontForContentSizeCategory = true
		titleLabel.label.numberOfLines = 2
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		titleLabel.snp.remakeConstraints { (make) in
			make.height.equalToSuperview().multipliedBy(0.12)
			make.top.equalTo(backButton.snp.bottom)
			make.left.equalToSuperview().inset(20)
			make.right.equalToSuperview().inset(20)
		}
		
		digitView.snp.makeConstraints { (make) in
			make.top.equalTo(titleLabel.snp.bottom)
			make.height.equalToSuperview().multipliedBy(0.6666)
			make.width.equalToSuperview().multipliedBy(0.8)
			make.centerX.equalToSuperview()
		}
		
		leftDigits.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.height.equalToSuperview()
			make.left.equalToSuperview().offset(-5)
			make.width.equalToSuperview().multipliedBy(0.5)
		}
		
		rightDigits.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.height.equalToSuperview()
			make.right.equalToSuperview().offset(5)
			make.width.equalToSuperview().multipliedBy(0.5)
		}
		
		vcDigit1.applyConstraint(rightMultiplier: 0.33333)
		vcDigit2.applyConstraint(rightMultiplier: 0.66666)
		vcDigit3.applyConstraint(rightMultiplier: 1.0)
		vcDigit4.applyConstraint(rightMultiplier: 0.33333)
		vcDigit5.applyConstraint(rightMultiplier: 0.66666)
		vcDigit6.applyConstraint(rightMultiplier: 1.0)
		
		resendButtonView.snp.makeConstraints { (make) in
			make.top.equalTo(leftDigits.snp.bottom)
			make.bottom.equalTo(nextButton.snp.top)
			make.width.equalToSuperview()
			make.left.equalTo(titleLabel)
		}
		
		resendVCButton.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.centerY.equalToSuperview()
			make.width.equalTo(250)
			make.height.equalTo(40)
		}
	}
}
