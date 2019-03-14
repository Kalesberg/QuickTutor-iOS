//
//  EmailVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class EmailVCView: BaseRegistrationView {
    
    let emailTextField : RegistrationTextField = {
        let registrationTextField = RegistrationTextField()
        registrationTextField.placeholder.text = "Email address"
        registrationTextField.textField.returnKeyType = .next
        registrationTextField.textField.keyboardType = .emailAddress
        registrationTextField.textField.autocapitalizationType = .none
        return registrationTextField
    }()
    
    override func setupViews() {
        super.setupViews()
        setupEmailTextField()
        setupErrorLabelBelow(emailTextField)
    }
    
    func setupEmailTextField() {
        addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.height.equalTo(100)
        }
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "What's your email?"
        titleLabelHeightAnchor?.constant = 30
        layoutIfNeeded()
    }
    
}
