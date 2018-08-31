//
//  ChangeEmail.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

class ChangeEmailView : MainLayoutTitleBackButton, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    
    var textField = NoPasteTextField()
    var line = UIView()
    fileprivate var subtitle = LeftTextLabel()
    fileprivate var updateEmailButton = UpdateEmailButton()
    
    override func configureView() {
        addSubview(textField)
        addSubview(subtitle)
        addSubview(updateEmailButton)
        addKeyboardView()
        textField.addSubview(line)
        super.configureView()
        
        title.label.text = "Change Email"
        
        subtitle.label.text = "Enter new Email address"
        subtitle.label.font = Fonts.createBoldSize(18)
        subtitle.label.numberOfLines = 2
        
        textField.tintColor = Colors.learnerPurple
        textField.font = Fonts.createSize(20)
        textField.isEnabled = true
        textField.textColor = Colors.grayText
        
        line.backgroundColor = Colors.registrationDark
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        subtitle.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(30)
        }
        textField.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.top.equalTo(subtitle.snp.bottom).inset(-20)
            make.centerX.equalToSuperview()
        }
        
        line.snp.makeConstraints { (make) in
            make.bottom.equalTo(textField).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(1)
            make.centerX.equalToSuperview()
        }
        
        updateEmailButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(keyboardView.snp.top)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.08)
            make.centerX.equalToSuperview()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if AccountService.shared.currentUserType == .tutor {
            navbar.backgroundColor = Colors.tutorBlue
            statusbarView.backgroundColor = Colors.tutorBlue
            updateEmailButton.backgroundColor = Colors.tutorBlue
            textField.tintColor = Colors.tutorBlue
        } else {
            navbar.backgroundColor = Colors.learnerPurple
            statusbarView.backgroundColor = Colors.learnerPurple
            updateEmailButton.backgroundColor = Colors.learnerPurple
            textField.tintColor = Colors.learnerPurple
        }
    }
}
fileprivate class ChangeEmailTextField : InteractableView, Interactable {
    
    var textField = NoPasteTextField()
    var line = UIView()
    
    override func configureView() {
        addSubview(textField)
        addSubview(line)
        super.configureView()
        
        textField.isEnabled = true
        textField.font = Fonts.createSize(18)
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.tintColor = .white
        textField.keyboardType = .emailAddress
        line.backgroundColor = .white
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        textField.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}

fileprivate class UpdateEmailButton : InteractableView, Interactable {
    
    var title = UILabel()
    
    override func configureView(){
        addSubview(title)
        super.configureView()
        
        isUserInteractionEnabled = true
        
        title.text = "Change Email"
        title.textColor = UIColor.white
        title.font = Fonts.createSize(20)
        title.textAlignment = .center
        title.adjustsFontSizeToFitWidth = true
        
        backgroundColor = UIColor(red: 0.3308961987, green: 0.2544008791, blue: 0.4683592319, alpha: 1)
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        title.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
}

class ChangeEmail : BaseViewController {
    
    override var contentView: ChangeEmailView{
        return view as! ChangeEmailView
    }
    
    override func loadView() {
        view = ChangeEmailView()
    }
	
	var verificationId : String?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.textField.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.textField.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentView.textField.resignFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	private func reauthenticateUser(code: String, completion: @escaping (Error?) -> Void) {
		guard let id = self.verificationId else { return }
		let credential : PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: id, verificationCode: code)
		let currentUser = Auth.auth().currentUser
		currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { (_, error) in
			if let error = error {
				completion(error)
			} else {
				completion(nil)
			}
		})
	}
	
	private func getUserCredentialsAlert() {
		let phoneNumber = CurrentUser.shared.learner.phone.cleanPhoneNumber()
		
		PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationId, error) in
			if let error = error {
				AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
			} else if let id = verificationId {
				self.verificationId = id
				self.displayPhoneVerificationAlert(message: "Please enter the verifcation code sent to: \(CurrentUser.shared.learner.phone.formatPhoneNumber())")
			} else {
				AlertController.genericErrorAlert(self, title: "Error", message: "Something went wrong, please try again.")
			}
		}
	}
	
    private func displaySavedAlertController() {
        let alertController = UIAlertController(title: "Saved!", message: "Your email update has been saved", preferredStyle: .alert)
        
        self.present(alertController, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            alertController.dismiss(animated: true){
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
	override func handleNavigation() {
		if (touchStartView is UpdateEmailButton) {
			guard let email = contentView.textField.text, email.emailRegex() else {
				AlertController.genericErrorAlert(self, title: "Invalid Email", message: "")
				self.contentView.textField.becomeFirstResponder()
				return
			}
			getUserCredentialsAlert()
		} else if touchStartView is PhoneAuthenicationActionCancel {
			self.dismissPhoneAuthenticationAlert()
		} else if touchStartView is PhoneAuthenicationAction {
			if let view = self.view.viewWithTag(321) as? PhoneAuthenticationAlertView {
				guard let verificationCode = view.verificationTextField.text, !verificationCode.contains("—") else { return }
				reauthenticateUser(code: verificationCode) { (error) in
					if let error = error {
						view.errorLabel.isHidden = false
						view.errorLabel.text = error.localizedDescription
					} else {
						if AccountService.shared.currentUserType == .learner {
							CurrentUser.shared.learner.email = self.contentView.textField.text!
						} else {
							CurrentUser.shared.tutor.email =  self.contentView.textField.text!
							CurrentUser.shared.learner.email =  self.contentView.textField.text!

						}
						FirebaseData.manager.updateValue(node: "account", value: ["em" : self.contentView.textField.text!], { (error) in
							if let error = error {
								AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
							}
						})
						self.dismissPhoneAuthenticationAlert()
						self.displaySavedAlertController()
					}
				}
			}
		}
	}
}
extension ChangeEmail : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxlength = 40
        guard let text = textField.text else {return true}
        let length = text.count + string.count - range.length
        
        if length <= maxlength { return true }
        else { return false }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        contentView.textField.becomeFirstResponder()
    }
}


