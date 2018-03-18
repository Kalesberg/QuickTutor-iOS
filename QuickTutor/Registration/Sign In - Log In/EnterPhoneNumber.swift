//
//  EnterPhoneNumber.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class PhoneTextField : InteractableView, Interactable {
    
    var textField = NoPasteTextField()
    var flag = UIImageView()
    var plusOneLabel = UILabel()
    var line = UIView()
    
    override func configureView() {
        addSubview(textField)
        addSubview(line)
        addSubview(flag)
        addSubview(plusOneLabel)
        super.configureView()
        
        textField.font = Fonts.createSize(25)
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.tintColor = .white
        
        flag.image = UIImage(named: "flag")
        flag.scaleImage()
        
        plusOneLabel.textColor = .white
        plusOneLabel.font = Fonts.createSize(25)
        plusOneLabel.text = "+1"
        plusOneLabel.textAlignment = .center
        
        line.backgroundColor = .white
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        flag.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.6)
            make.width.equalTo(30)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        plusOneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(flag.snp.right)
            make.bottom.equalToSuperview()
            make.width.equalTo(45)
            make.height.equalTo(flag)
        }
        
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(plusOneLabel.snp.right)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(1)
            make.height.equalTo(1)
        }
    }
}


class EnterPhoneNumberView : RegistrationGradientView, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    
    var backButton = RegistrationBackButton()
    var titleLabel = RegistrationTitleLabel()
    
    var container = UIView()
    var textField = NoPasteTextField()
    var flag = UIImageView()
    var plusOneLabel = UILabel()
    var line = UIView()
    
    var nextButton = RegistrationNextButton()
    
    override func configureView() {
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(container)
        container.addSubview(textField)
        container.addSubview(line)
        container.addSubview(flag)
        container.addSubview(plusOneLabel)
        addSubview(nextButton)
        super.configureView()
        
        addKeyboardView()
        
        titleLabel.label.text = "Enter your mobile number"
        
        textField.font = Fonts.createSize(25)
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.tintColor = .white
        
        flag.image = UIImage(named: "flag")
        flag.scaleImage()
        
        plusOneLabel.textColor = .white
        plusOneLabel.font = Fonts.createSize(25)
        plusOneLabel.text = "+1"
        plusOneLabel.textAlignment = .center
        
        line.backgroundColor = .white
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.13)
            make.left.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backButton.button.snp.left)
            make.right.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom)
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.05)
        }
        
        container.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.1)
            make.right.equalTo(layoutMarginsGuide.snp.right)
        }
        
        flag.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.6)
            make.width.equalTo(30)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        plusOneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(flag.snp.right)
            make.bottom.equalToSuperview()
            make.width.equalTo(45)
            make.height.equalTo(flag)
        }
        
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(plusOneLabel.snp.right)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(1)
            make.height.equalTo(1)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(keyboardView.snp.top)
            make.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
    }
}


class EnterPhoneNumber: BaseViewController {
    
    override var contentView: EnterPhoneNumberView {
        return view as! EnterPhoneNumberView
    }
    
    override func loadView() {
        view = EnterPhoneNumberView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.textField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        contentView.textField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func handleNavigation() {
        if(touchStartView == contentView.nextButton) {
            signIn()
        } 
    }
    
    private func signIn() {
        let phoneNumber = contentView.textField.text!
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber.cleanPhoneNumber(), uiDelegate: nil) { (verificationId, error) in
            if let error = error {
                print("Error: ", error.localizedDescription)
            } else {
                
                UserDefaults.standard.set(verificationId, forKey: Constants.VRFCTN_ID)
                Registration.phone = phoneNumber.cleanPhoneNumber()
                self.navigationController?.pushViewController(Verification(), animated: true)
            }
        }
    }
}


extension EnterPhoneNumber : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)
        
        let decimalString = components.joined(separator: "") as NSString
        let length = decimalString.length
        let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
        
        if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            
            return (newLength > 10) ? false : true
        }
        var index = 0 as Int
        let formattedString = NSMutableString()
        
        if hasLeadingOne {
            formattedString.append("1 ")
            index += 1
        }
        if (length - index) > 3 {
            let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("(%@) ", areaCode)
            index += 3
        }
        if length - index > 3 {
            let prefix = decimalString.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", prefix)
            index += 3
        }
        
        let remainder = decimalString.substring(from: index)
        formattedString.append(remainder)
        textField.text = formattedString as String
        return false
    }
}
