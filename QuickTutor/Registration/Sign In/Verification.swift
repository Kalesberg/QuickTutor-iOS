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
    var resendVCButton   = ResendButton()
	
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
        
        progressBar.progress = 1
        progressBar.applyConstraints()
        progressBar.divider.isHidden = true
        
		titleLabel.label.text = "Enter the 6-digit code we've sent to: \(Registration.phone.formatPhoneNumber())"

		titleLabel.label.adjustsFontSizeToFitWidth = true
        titleLabel.label.adjustsFontForContentSizeCategory = true
        titleLabel.label.numberOfLines = 2
		
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
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(250)
            make.height.equalTo(40)
        }
    }
}

class ResendButton : InteractableView, Interactable {
    
    let label : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createSize(18)
        label.text = "Resend verification code »"
        
        return label
    }()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func touchStart() {
        label.alpha = 0.6
    }
    
    func didDragOff() {
        label.alpha = 1.0
    }
}


class VerificationVC : BaseViewController {
	
	private var ref: DatabaseReference!
	
    override var contentView: VerificationView {
        return view as! VerificationView
    }
    
    override func loadView() {
        view = VerificationView()
    }
	
	var verificationCode : String = ""
	var index : Int = 0
	var textFields : [UITextField] = []
    
    var timer = Timer()
    var seconds = 15
	
    override func viewDidLoad() {
        super.viewDidLoad()
		hideKeyboardWhenTappedAround()
        ref = Database.database().reference(fromURL: Constants.DATABASE_URL)
        
		textFields = [contentView.vcDigit1.textField, contentView.vcDigit2.textField, contentView.vcDigit3.textField, contentView.vcDigit4.textField, contentView.vcDigit5.textField, contentView.vcDigit6.textField]
		
		configureTextFields()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

	}
    override func viewDidAppear(_ animated: Bool) {
		textFields[0].becomeFirstResponder()
    }
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		contentView.resignFirstResponder()
	}
	
	private func configureTextFields() {
		for textField in textFields {
			textField.delegate = self
			textField.isEnabled = false
		}
		textFields[0].isEnabled = true
	}
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        seconds -= 1
        if seconds == -1 {
            contentView.resendVCButton.label.text = "Resend verification code »"
            contentView.resendVCButton.isUserInteractionEnabled = true
            timer.invalidate()
            seconds = 15
        } else {
            if seconds >= 10 {
                contentView.resendVCButton.label.text = "Resend code in: 0:\(seconds)"
            } else {
                contentView.resendVCButton.label.text = "Resend code in: 0:0\(seconds)"
            }
        }
    }
	
    override func handleNavigation() {
        if(touchStartView == contentView.backButton) {
			navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
			navigationController!.popViewController(animated: false)
		} else if (touchStartView == contentView.nextButton) {
			var verificationCode : String = ""
			textFields.forEach { verificationCode.append($0.text!)}
			createCredential(verificationCode)
		} else if (touchStartView == contentView.resendVCButton){
            contentView.resendVCButton.isUserInteractionEnabled = false
            resendVCAction()
        }
    }
    
    private func textFieldController(current: UITextField, textFieldToChange: UITextField) {
        current.isEnabled = false
        textFieldToChange.isEnabled = true
    }
	
    private func createCredential(_ verificationCode: String) {
		if verificationCode.count != 6 {
			return displayCredentialError()
		}
		let verificationId = UserDefaults.standard.value(forKey: Constants.VRFCTN_ID)
		let credential : PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId! as! String, verificationCode: verificationCode)
        signInRegisterWithCredential(credential)
    }
    
    private func displayCredentialError() {
        UIView.animate(withDuration: 0.5, animations: {
            for view in self.contentView.leftDigits.subviews + self.contentView.rightDigits.subviews {
                if view is RegistrationDigitTextField {
                    let digit = (view as! RegistrationDigitTextField)
                    digit.line.backgroundColor = .red
                }
            }
        }, completion: { (value: Bool) in
            UIView.animate(withDuration: 0.5, animations: {
                for view in self.contentView.leftDigits.subviews + self.contentView.rightDigits.subviews {
                    if view is RegistrationDigitTextField {
                        let digit = (view as! RegistrationDigitTextField)
                        
                        digit.line.backgroundColor = .white
                    }
                }
            }, completion: { (value: Bool) in
                for view in self.contentView.leftDigits.subviews + self.contentView.rightDigits.subviews {
                    if view is RegistrationDigitTextField {
                        let digit = (view as! RegistrationDigitTextField)
                        digit.textField.fadeOut(withDuration: 0.3)
                        digit.textField.alpha = 1.0
                    }
                }
            })
        })
    }
    
    private func signInRegisterWithCredential(_ credential: PhoneAuthCredential) {
		self.displayLoadingOverlay()
		contentView.nextButton.isUserInteractionEnabled = false
       Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if error != nil {
				self.contentView.nextButton.isUserInteractionEnabled = true
				self.contentView.vcDigit6.textField.isEnabled = true
				self.displayCredentialError()
            } else {
                self.view.endEditing(true)
				guard let user = authResult?.user else { return }
                self.ref.child("student-info").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
						UserDefaults.standard.set(true, forKey: "showHomePage")
							if UserDefaults.standard.bool(forKey: "showHomePage") {
								FirebaseData.manager.signInLearner(uid: user.uid) { (successful) in
									if successful {
										Registration.setLearnerDefaults()
									self.navigationController?.pushViewController(LearnerPageViewController(), animated: true)
									} else {
										self.navigationController?.pushViewController(SignInVC(), animated: true)
									}
								}
							} else {
								FirebaseData.manager.signInTutor(uid: user.uid) { (successful) in
									if successful {
										Registration.setTutorDefaults()
										self.navigationController?.pushViewController(TutorPageViewController(), animated: true)
									} else {
										self.navigationController?.pushViewController(SignInVC(), animated: true)
									}
								}
						}
                    } else {
						Registration.uid = user.uid
						AccountService.shared.currentUserType = .lRegistration
                        self.navigationController!.pushViewController(Name(), animated: true)
                    }
                })
            }
			self.dismissOverlay()
        }
    }

    private func resendVCAction() {
        PhoneAuthProvider.provider().verifyPhoneNumber(Registration.phone, uiDelegate: nil) { (verificationId, error) in
            if let error = error {
				AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
				self.contentView.resendVCButton.isUserInteractionEnabled = true
                return
            }else{
                self.runTimer()
                UserDefaults.standard.set(verificationId, forKey: Constants.VRFCTN_ID)
                UserDefaults.standard.synchronize()
            }
        }
    }
}

extension VerificationVC : UITextFieldDelegate {
    
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let char = string.cString(using: String.Encoding.utf8)!
		let isBackSpace = strcmp(char, "\\b")
		
		let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
		let components = string.components(separatedBy: inverseSet)
		let filtered = components.joined(separator: "")
		
		guard string == filtered else { return false }

		if (index == 0) && (isBackSpace == Constants.BCK_SPACE) {
			textFields[index].text = ""
			return true
		} else if isBackSpace == Constants.BCK_SPACE {
			textFields[index].text = ""
			textFieldController(current: textFields[index], textFieldToChange: textFields[index - 1])
			index -= 1
			textFields[index].becomeFirstResponder()
			return false
		}
		
		if index < 5 {
			if textField.text == "" {
				textField.text = string
				return false
			}
			textFieldController(current: textFields[index], textFieldToChange: textFields[index + 1])
			index += 1
			textFields[index].becomeFirstResponder()
			textFields[index].text = string
			return false
		}
		if index == 5 {
			return (textFields[index].text  == "") ? true : false
		}
		return false
	}
}
