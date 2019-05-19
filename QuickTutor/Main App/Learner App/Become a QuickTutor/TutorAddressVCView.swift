//
//  TutorAddressVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/17/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorAddressVCView: BaseRegistrationView {
    
    let addressLine1TextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.placeholder.text = "Address"
        field.textField.autocapitalizationType = .words
        field.textField.returnKeyType = .next
        return field
    }()
    
    let cityTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.placeholder.text = "City"
        field.textField.autocapitalizationType = .words
        field.textField.returnKeyType = .next
        return field
    }()
    
    let stateTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.placeholder.text = "State"
        field.textField.autocapitalizationType = .allCharacters
        field.textField.returnKeyType = .next
        return field
    }()
    
    let zipTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.placeholder.text = "Postal code"
        field.textField.returnKeyType = .next
        field.textField.keyboardType = .numberPad
        return field
    }()
    
    override func setupViews() {
        super.setupViews()
        setupAddressLine1TextField()
        setupCityTextField()
        setupStateTextField()
        setupZipTextField()
    }
    
    func setupAddressLine1TextField() {
        addSubview(addressLine1TextField)
        addressLine1TextField.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 100)
    }
    
    func setupCityTextField() {
        addSubview(cityTextField)
        cityTextField.anchor(top: addressLine1TextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 100)
    }
    
    func setupStateTextField() {
        addSubview(stateTextField)
        stateTextField.anchor(top: cityTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 0, width: 150, height: 100)
    }
    
    func setupZipTextField() {
        addSubview(zipTextField)
        zipTextField.anchor(top: cityTextField.bottomAnchor, left: stateTextField.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 30, width: 0, height: 100)
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "Billing address"
        titleLabelHeightAnchor?.constant = 30
        layoutIfNeeded()
    }
    
}
