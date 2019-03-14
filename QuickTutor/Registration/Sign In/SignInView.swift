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
        button.backgroundColor = Colors.purple
        button.setTitle("Login via Facebook", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.layer.cornerRadius = 4
        return button
    }()
    
    let infoLabel : UILabel = {
        let label = UILabel()
        label.text = "By tapping continue or entering a mobile phone number, I agree to QuickTutor's Service Terms of Use, Privacy Policy, Payments Terms of Service, and Nondiscrimination Policy."
        label.numberOfLines = 0
        label.textColor = .white
        label.font = Fonts.createSize(12)
        return label
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
        setupInfoLabel()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupLogoImageView() {
        addSubview(logoImageView)
        logoImageView.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, right: nil, paddingTop: 80, paddingLeft: 30, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
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
        facebookButton.anchor(top: orLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 40, paddingLeft: 80, paddingBottom: 0, paddingRight: 80, width: 0, height: 45)
    }
    
    func setupPatentLabel() {
        addSubview(patentLabel)
        patentLabel.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 15)
    }
    
    func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.anchor(top: nil, left: leftAnchor, bottom: patentLabel.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 50)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
