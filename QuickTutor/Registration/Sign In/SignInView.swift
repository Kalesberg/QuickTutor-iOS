//
//  SignInView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class SignInVCView: UIView {
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "launchScreenImage")
        return iv
    }()
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to QuickTutor!"
        label.textColor = .white
        label.font = Fonts.createBlackSize(24)
        label.numberOfLines = 0
        return label
    }()
    
    let phoneTextField : PhoneTextFieldView = {
        let view = PhoneTextFieldView()
        view.textField.keyboardType = .numberPad
        return view
    }()
    
    let orLabel: UILabel = {
        let label = UILabel()
        label.text = "or"
        label.textAlignment = .center
        label.font = Fonts.createSize(16)
        label.textColor = Colors.registrationGray
        return label
    }()
    
    let facebookButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.facebookColor
        button.setTitle("Login via Facebook", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.layer.cornerRadius = 4
        return button
    }()
    
    let infoTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.isEditable = false
        textView.backgroundColor = Colors.newScreenBackground
        textView.isUserInteractionEnabled = true
        textView.font = Fonts.createSize(12)
        textView.isScrollEnabled = false
        textView.attributedText = NSMutableAttributedString()
            .regular("By entering your mobile phone number or tapping the “Login via Facebook” button, you are agreeing to QuickTutor’s ", 12, .white)
            .underline("Service Terms of Use",12, .white, id: "terms-of-service").regular(", ", 12, .white)
            .underline("Privacy Policy",12, .white, id: "privacy-policy").regular(", ", 12, .white)
            .underline("Payments Terms of Service",12, .white, id: "payment-terms-of-service").regular(", ", 12, .white)
            .regular(" and ",12, .white).regular(" ", 12, .white)
            .underline("Nondiscrimination Policy ", 12, .white, id: "nondiscrimintation-policy").regular(" ", 12, .white)
        return textView
    }()
    
    let patentLabel: UILabel = {
        let label = UILabel()
        label.text = "U.S. Patent Pending"
        label.textColor = Colors.registrationGray
        label.font = Fonts.createBoldSize(14)
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupLogoImageView()
        setupWelcomeLabel()
        setupPhoneTextField()
        setupOrLabel()
        setupFacebookButton()
        setupPatentLabel()
        setupInfoTextView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupLogoImageView() {
        addSubview(logoImageView)
        logoImageView.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, right: nil, paddingTop: 80, paddingLeft: 30, paddingBottom: 0, paddingRight: 0, width: 55, height: 55)
    }
    
    func setupWelcomeLabel() {
        addSubview(welcomeLabel)
        welcomeLabel.anchor(top: logoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 0, width: 166, height: 72)
    }
    
    func setupPhoneTextField() {
        addSubview(phoneTextField)
        phoneTextField.anchor(top: welcomeLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 80, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 105)
    }
    
    func setupOrLabel() {
        addSubview(orLabel)
        orLabel.anchor(top: phoneTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 21)
    }
    
    func setupFacebookButton() {
        addSubview(facebookButton)
        facebookButton.anchor(top: orLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 37, paddingLeft: 80, paddingBottom: 0, paddingRight: 80, width: 0, height: 45)
    }
    
    func setupPatentLabel() {
        addSubview(patentLabel)
        patentLabel.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 15)
    }
    
    func setupInfoTextView() {
        addSubview(infoTextView)
        infoTextView.anchor(top: nil, left: leftAnchor, bottom: patentLabel.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 17, paddingBottom: 15, paddingRight: 16, width: 0, height: 80)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
