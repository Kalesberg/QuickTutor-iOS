//
//  Verification.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/16/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase

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
    var resendVCButton   = UIButton()
	
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
        
        navBar.progress = 0.142
        navBar.applyConstraints()
        
        titleLabel.label.text = "Enter the 6-digit code we've sent to: \(Registration.phone.formatPhoneNumber())"

		titleLabel.label.adjustsFontSizeToFitWidth = true
        titleLabel.label.adjustsFontForContentSizeCategory = true
        titleLabel.label.numberOfLines = 2
        
        resendVCButton.setTitle("Resend verification code »", for: .normal)
        resendVCButton.titleLabel?.font = Fonts.createSize(18)
        resendVCButton.setTitleColor(.white, for: .normal)
		
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
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.left.equalToSuperview()
        }
    }
}

class Verification : BaseViewController {
    
    override var contentView: VerificationView {
        return view as! VerificationView
    }
    
    override func loadView() {
        view = VerificationView()
    }
    
    private var ref: DatabaseReference!
    private var verificationCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(fromURL: Constants.DATABASE_URL)
        
        let textFields = [contentView.vcDigit1.textField, contentView.vcDigit2.textField, contentView.vcDigit3.textField, contentView.vcDigit4.textField, contentView.vcDigit5.textField, contentView.vcDigit6.textField]
        
        for textField in textFields {
            textField.isEnabled = false
            textField.tintColor = .clear
            textField.delegate = self
            textField.addTarget(self, action: #selector(buildVerificationCode(_:)), for: .editingChanged)
        }
		contentView.vcDigit1.textField.isEnabled = true
    }
    override func viewDidAppear(_ animated: Bool) {
        contentView.vcDigit1.textField.becomeFirstResponder()
    }
	override func viewWillDisappear(_ animated: Bool) {
		contentView.resignFirstResponder()
	}
    
    override func handleNavigation() {
        if(touchStartView == contentView.backButton) {
			navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
			navigationController!.popViewController(animated: false)
		}
        if (touchStartView == contentView.resendVCButton){
            resendVCAction()
        }
    }
    
    private func textFieldController(current: UITextField, textFieldToChange: UITextField) {
        current.isEnabled = false
        textFieldToChange.isEnabled = true
    }
    
    //going to fix this...
    @objc
    private func buildVerificationCode(_ textField: UITextField) {
        verificationCode.append(textField.text!)
        if (verificationCode.count == 6) {
            createCredential(verificationCode)
        }
    }
    
    private func createCredential(_ verificationCode: String) {
        let verificationId = UserDefaults.standard.value(forKey: Constants.VRFCTN_ID)
        let credential : PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId! as! String, verificationCode: verificationCode)
        
        signInRegisterWithCredential(credential)
    }
    
    private func signInRegisterWithCredential(_ credential: PhoneAuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Error", error.localizedDescription)
                self.contentView.vcDigit6.textField.isEnabled = true
            } else {
                self.view.endEditing(true)
                self.ref.child("student").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
						SignInHandler.manager.getUserData(completion: { (error) in
							if error != nil {
								print(error ?? "Sign In Error")
							} else {
								Stripe.stripeManager.retrieveCustomer({ (error) in
									if let error = error {
										print(error.localizedDescription)
									}
									self.navigationController!.pushViewController(MainPage(), animated: true)
								})
							}
						})
                    } else {
                        self.navigationController!.pushViewController(Name(), animated: true)
                    }
                })
            }
        }
    }

    
    private func resendVCAction() {
        PhoneAuthProvider.provider().verifyPhoneNumber(Registration.phone, uiDelegate: nil) { (verificationId, error) in
            if let error = error {
                print("Error: ", error.localizedDescription)
                return
            }else{
                UserDefaults.standard.set(verificationId, forKey: Constants.VRFCTN_ID)
                UserDefaults.standard.synchronize()
            }
        }
    }
}

extension Verification : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")
        
        if textField.text!.count == 1 {
            
            switch(textField) {
            case contentView.vcDigit1.textField:
                if (isBackSpace == Constants.BCK_SPACE){
                    contentView.vcDigit1.textField.text = ""
                    self.verificationCode.removeLast()
                    return false
                }else{
                    textFieldController(current: contentView.vcDigit1.textField, textFieldToChange: contentView.vcDigit2.textField)
                    contentView.vcDigit2.textField.becomeFirstResponder()
                    return true
                }
            case contentView.vcDigit2.textField:
                if(isBackSpace == Constants.BCK_SPACE){
                    contentView.vcDigit2.textField.text = ""
                    textFieldController(current: contentView.vcDigit2.textField, textFieldToChange: contentView.vcDigit1.textField)
                    contentView.vcDigit1.textField.becomeFirstResponder()
                    self.verificationCode.removeLast()
                    return false
                }else{
                    textFieldController(current: contentView.vcDigit2.textField, textFieldToChange: contentView.vcDigit3.textField)
                    contentView.vcDigit3.textField.becomeFirstResponder()
                    return true
                }
            case contentView.vcDigit3.textField:
                if(isBackSpace == Constants.BCK_SPACE) {
                    contentView.vcDigit3.textField.text = ""
                    textFieldController(current: contentView.vcDigit3.textField, textFieldToChange: contentView.vcDigit2.textField)
                    contentView.vcDigit2.textField.becomeFirstResponder()
                    self.verificationCode.removeLast()
                    return false
                }else{
                    textFieldController(current: contentView.vcDigit3.textField, textFieldToChange: contentView.vcDigit4.textField)
                    contentView.vcDigit4.textField.becomeFirstResponder()
                    return true
                }
            case contentView.vcDigit4.textField:
                if (isBackSpace == Constants.BCK_SPACE){
                    contentView.vcDigit4.textField.text = ""
                    textFieldController(current: contentView.vcDigit4.textField, textFieldToChange: contentView.vcDigit3.textField)
                    contentView.vcDigit3.textField.becomeFirstResponder()
                    self.verificationCode.removeLast()
                    return false
                }else{
                    textFieldController(current: contentView.vcDigit4.textField, textFieldToChange: contentView.vcDigit5.textField)
                    contentView.vcDigit5.textField.becomeFirstResponder()
                    return true
                }
            case contentView.vcDigit5.textField:
                if (isBackSpace == Constants.BCK_SPACE){
                    contentView.vcDigit5.textField.text = ""
                    textFieldController(current: contentView.vcDigit5.textField, textFieldToChange: contentView.vcDigit4.textField)
                    contentView.vcDigit4.textField.becomeFirstResponder()
                    self.verificationCode.removeLast()
                    return false
                }else{
                    textFieldController(current: contentView.vcDigit5.textField, textFieldToChange: contentView.vcDigit6.textField)
                    contentView.vcDigit6.textField.becomeFirstResponder()
                    return true
                }
            case contentView.vcDigit6.textField:
                if (isBackSpace == Constants.BCK_SPACE){
                    contentView.vcDigit6.textField.text = ""
                    textFieldController(current: contentView.vcDigit6.textField, textFieldToChange: contentView.vcDigit5.textField)
                    contentView.vcDigit5.textField.becomeFirstResponder()
                    self.verificationCode.removeLast()
                    return false
                } else {
                    return false
                }
            default:
                contentView.vcDigit6.textField.becomeFirstResponder()
                return false
            }
        }
        return string == filtered
    }
}
