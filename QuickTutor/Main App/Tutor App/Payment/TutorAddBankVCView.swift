//
//  TutorAddBankVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/16/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorAddBankView: BaseRegistrationView {
    
    let nameTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.placeholder.text = "Account holder name"
        field.textField.autocapitalizationType = .words
        field.textField.returnKeyType = .next
        return field
    }()
    
    let routingNumberTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.placeholder.text = "Routing number"
        field.textField.returnKeyType = .next
        field.textField.keyboardType = .numberPad
        return field
    }()
    
    let accountNumberTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.placeholder.text = "Account number"
        field.textField.returnKeyType = .next
        field.textField.keyboardType = .numberPad
        return field
    }()
    
    override func setupViews() {
        super.setupViews()
        setupNameField()
        setupRoutingNumberField()
        setupAccountNumberField()
    }
    
    func setupNameField() {
        addSubview(nameTextField)
        nameTextField.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 100)
    }
    
    func setupRoutingNumberField() {
        addSubview(routingNumberTextField)
        routingNumberTextField.anchor(top: nameTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: -10, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 100)
    }
    
    func setupAccountNumberField() {
        addSubview(accountNumberTextField)
        accountNumberTextField.anchor(top: routingNumberTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: -10, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 100)
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "Add bank"
    }
    
}
