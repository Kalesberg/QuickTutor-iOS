//
//  TutorAddBankVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/16/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorAddBankView: BaseRegistrationView {
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        
        let attributedString = NSMutableAttributedString(string: "Please enter the account holder information for your bank account.")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        label.font = Fonts.createSize(16)
        label.textColor = Colors.registrationGray
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let infoButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "informationIcon")
        let tintedImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = Colors.purple
        return button
    }()
    
    let nameTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.placeholder.text = "Name"
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
    
    let routingNumberInfoButton: UIButton = {
       let button = UIButton(type: .custom)
        let image = UIImage(named: "informationIcon")
        let tintedImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = Colors.purple
        return button
    }()
    
    let accountNumberTextField: RegistrationTextField = {
        let field = RegistrationTextField()
        field.placeholder.text = "Account number"
        field.textField.returnKeyType = .next
        field.textField.keyboardType = .numberPad
        return field
    }()
    
    let accountNumberInfoButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "informationIcon")
        let tintedImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = Colors.purple
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        setupSubtitleLabel()
        setupInfoButton()
        setupNameField()
        setupRoutingNumberField()
        setupRoutingNumberInfoButton()
        setupAccountNumberField()
        setupAccountNumberInfoButton()
    }
    
    func setupSubtitleLabel() {
        addSubview(subtitleLabel)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 42)
    }
    
    func setupInfoButton() {
        addSubview(infoButton)
        infoButton.anchor(top: nil, left: titleLabel.rightAnchor, bottom: titleLabel.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 44, height: 44)
    }
    
    func setupNameField() {
        addSubview(nameTextField)
        nameTextField.anchor(top: subtitleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 100)
    }
    
    func setupRoutingNumberField() {
        addSubview(routingNumberTextField)
        routingNumberTextField.anchor(top: nameTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: -10, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 100)
    }
    
    func setupRoutingNumberInfoButton() {
        addSubview(routingNumberInfoButton)
        routingNumberInfoButton.anchor(top: nil, left: nil, bottom: routingNumberTextField.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 20, width: 44, height: 44)
    }
    
    func setupAccountNumberField() {
        addSubview(accountNumberTextField)
        accountNumberTextField.anchor(top: routingNumberTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: -10, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 100)
    }
    
    func setupAccountNumberInfoButton() {
        addSubview(accountNumberInfoButton)
        accountNumberInfoButton.anchor(top: nil, left: nil, bottom: accountNumberTextField.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 20, width: 44, height: 44)
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "Bank information"
    }
}
