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
		
		nextButton.isUserInteractionEnabled = false

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


class Verification : BaseViewController {
	
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
	
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference(fromURL: Constants.DATABASE_URL)
        
		textFields = [contentView.vcDigit1.textField, contentView.vcDigit2.textField, contentView.vcDigit3.textField, contentView.vcDigit4.textField, contentView.vcDigit5.textField, contentView.vcDigit6.textField]
		
		configureTextFields()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		contentView.nextButton.isUserInteractionEnabled = false
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
			textField.addTarget(self, action: #selector(buildLast4SSN(_:)), for: .editingChanged)
		}
		textFields[0].isEnabled = true
	}
	
	@objc private func buildLast4SSN(_ textField: UITextField) {
		guard let first = textFields[0].text, first != "" else {
			print("not valid")
			return
		}
		guard let second = textFields[1].text, second != "" else {
			print("not valid")
			return
		}
		guard let third = textFields[2].text, third != "" else {
			print("not valid")
			return
		}
		guard let forth = textFields[3].text, forth != "" else {
			print("not valid")
			return
		}
		guard let fifth = textFields[4].text, fifth != "" else {
			print("not valid")
			return
		}
		guard let sixth = textFields[5].text, sixth != "" else {
			print("not valid")
			return
		}
		verificationCode = first + second + third + forth + fifth + sixth
		contentView.nextButton.isUserInteractionEnabled = true
	}
	
    override func handleNavigation() {
        if(touchStartView == contentView.backButton) {
			navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
			navigationController!.popViewController(animated: false)
		} else if (touchStartView == contentView.nextButton){
			createCredential(verificationCode)
			contentView.nextButton.isUserInteractionEnabled = false
		} else if (touchStartView == contentView.resendVCButton){
            resendVCAction()
        }
    }
    
    private func textFieldController(current: UITextField, textFieldToChange: UITextField) {
        current.isEnabled = false
        textFieldToChange.isEnabled = true
    }
	
    private func createCredential(_ verificationCode: String) {
		let verificationId = UserDefaults.standard.value(forKey: Constants.VRFCTN_ID)
		let credential : PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId! as! String, verificationCode: verificationCode)
        signInRegisterWithCredential(credential)
    }
    
    private func signInRegisterWithCredential(_ credential: PhoneAuthCredential) {
		self.displayLoadingOverlay()
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
				print("Error: SIGNING IN WITH CREDENTIAL FAILED", error.localizedDescription)
                self.contentView.vcDigit6.textField.isEnabled = true
				self.contentView.nextButton.isUserInteractionEnabled = true
				self.dismissOverlay()
            } else {
                self.view.endEditing(true)
                self.ref.child("student-info").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
						UserDefaults.standard.set(true, forKey: "showHomePage")
							if UserDefaults.standard.bool(forKey: "showHomePage") {
								FirebaseData.manager.signInLearner(uid: user!.uid) { (successful) in
									if successful {
										self.dismissOverlay()
									self.navigationController?.pushViewController(LearnerPageViewController(), animated: true)
									} else {
										self.dismissOverlay()
										try! Auth.auth().signOut()
										self.navigationController?.pushViewController(SignIn(), animated: true)
									}
								}
							} else {
								FirebaseData.manager.signInTutor(uid: user!.uid) { (successful) in
									if successful {
										self.dismissOverlay()
										self.navigationController?.pushViewController(TutorPageViewController(), animated: true)
									} else {
										self.dismissOverlay()
										try! Auth.auth().signOut()
										self.navigationController?.pushViewController(SignIn(), animated: true)
									}
								}
						}
                    } else {
						self.dismissOverlay()
						Registration.uid = user!.uid
						AccountService.shared.currentUserType = .lRegistration
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
		
		guard let text = textField.text else { return true }
		let newLength = text.count + string.count - range.length
		
		if (index == 0) && (isBackSpace == Constants.BCK_SPACE) {
			textFields[index].text = ""
			return true
		}
		
		if isBackSpace == Constants.BCK_SPACE {
			textFields[index].text = ""
			textFieldController(current: textFields[index], textFieldToChange: textFields[index - 1])
			textFields[index - 1].becomeFirstResponder()
			index -= 1
			contentView.nextButton.isUserInteractionEnabled = false
			return false
		}
		
		if (index == 5) {
			return false
		}
		
		if newLength > 1 {
			textFieldController(current: textFields[index], textFieldToChange: textFields[index + 1])
			index += 1
			textFields[index].becomeFirstResponder()
			return string == filtered
		} else {
			return string == filtered
		}
	}
}
