//
//  SignInView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import FBSDKLoginKit

protocol SignInVCViewDelegate: class {
    func backButtonTapped()
}

class SignInVCView: UIView {
    
    weak var delegate: SignInVCViewDelegate?
    
    let getStartedLabel: UILabel = {
        let label = UILabel()
        label.text = "Get Started"
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
            .underline("Non-Discrimination Policy ", 12, .white, id: "nondiscrimintation-policy").regular(" ", 12, .white)
        return textView
    }()
    
    let patentLabel: UILabel = {
        let label = UILabel()
        label.text = "U.S. Patent Pending"
        label.textColor = Colors.registrationGray
        label.font = Fonts.createBoldSize(14)
        return label
    }()
    
    let backButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let backArrowImage = UIImage(named: "ic_back_arrow")
        button.setImage(backArrowImage, for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    func setupViews() {
        setupMainView()
        setupBackButton()
        setupGetStartedLabel()
        setupPhoneTextField()
        setupOrLabel()
        setupFacebookButton()
        setupPatentLabel()
        setupInfoTextView()
        setupRightSwipe()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupBackButton() {
        addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 30),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 60)
            ])
    }
    
    func setupGetStartedLabel() {
        addSubview(getStartedLabel)
        getStartedLabel.anchor(top: backButton.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 0, width: 166, height: 72)
    }
    
    func setupPhoneTextField() {
        addSubview(phoneTextField)
        phoneTextField.anchor(top: getStartedLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 80, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 105)
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
    
    func setupRightSwipe(){
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe(sender:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.addGestureRecognizer(swipeRight)
    }
    
    @objc func backButtonTapped() {
        delegate?.backButtonTapped()
    }
    
    @objc func swipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.right:
        delegate?.backButtonTapped()
        default:
            break
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
