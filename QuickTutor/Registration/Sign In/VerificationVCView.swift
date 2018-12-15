//
//  VerificationView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class VerificationVCView: BaseRegistrationView {
    
    var vcDigit1 = RegistrationDigitTextField()
    var vcDigit2 = RegistrationDigitTextField()
    var vcDigit3 = RegistrationDigitTextField()
    var vcDigit4 = RegistrationDigitTextField()
    var vcDigit5 = RegistrationDigitTextField()
    var vcDigit6 = RegistrationDigitTextField()
    
    var digitView = UIView()
    var leftDigits = UIView()
    var rightDigits = UIView()
    
    let resendVCButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(Colors.registrationGray, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = Fonts.createSize(14)
        button.setTitle("Resend verification code »", for: .normal)
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        setupInputField()
        setupResendButton()
        updateTitleLabel()
    }
    
    func setupInputField() {
        setupLeftDigits()
        setupRightDigits()
        setupDigitView()
    }
    
    func setupLeftDigits() {
        digitView.addSubview(leftDigits)
        leftDigits.addSubview(vcDigit1)
        leftDigits.addSubview(vcDigit2)
        leftDigits.addSubview(vcDigit3)
        
        leftDigits.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalToSuperview().offset(-5)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        vcDigit1.applyConstraint(rightMultiplier: 0.33333)
        vcDigit2.applyConstraint(rightMultiplier: 0.66666)
        vcDigit3.applyConstraint(rightMultiplier: 1.0)
    }
    
    func setupRightDigits() {
        digitView.addSubview(rightDigits)
        rightDigits.addSubview(vcDigit4)
        rightDigits.addSubview(vcDigit5)
        rightDigits.addSubview(vcDigit6)
        
        rightDigits.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.right.equalToSuperview().offset(5)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        vcDigit4.applyConstraint(rightMultiplier: 0.33333)
        vcDigit5.applyConstraint(rightMultiplier: 0.66666)
        vcDigit6.applyConstraint(rightMultiplier: 1.0)
    }
    
    func setupDigitView() {
        addSubview(digitView)
        digitView.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-75)
        }
    }
    
    func setupResendButton() {
        addSubview(resendVCButton)
        resendVCButton.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(leftDigits.snp.bottom)
            make.width.equalTo(250)
            make.height.equalTo(30)
        }
    }
    
    func updateTitleLabel() {
        titleLabel.text = "Enter the 6-digit code we've sent to: 334-328-7720"
        if let phone = Registration.phone {
            titleLabel.text = "Enter the 6-digit code we've sent to: \(phone.formatPhoneNumber())"
        }
    }

}
