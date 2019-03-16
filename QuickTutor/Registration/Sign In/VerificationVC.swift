//
//  Verification.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/16/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase

class VerificationVC: BaseRegistrationController {
    
    let contentView: VerificationVCView = {
        let view = VerificationVCView()
        return view
    }()
    
    override var inputAccessoryView: UIView? {
        return RegistrationAccessoryView()
    }
    
    override func loadView() {
        view = contentView
    }
    
    var verificationCode: String = ""
    var index: Int = 0
    var textFields: [UITextField] = []
    
    var timer = Timer()
    var seconds = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        contentView.resendVCButton.addTarget(self, action: #selector(resendVCButtonPressed(_:)), for: .touchUpInside)
        
        textFields = [contentView.vcDigit1.textField, contentView.vcDigit2.textField, contentView.vcDigit3.textField, contentView.vcDigit4.textField, contentView.vcDigit5.textField, contentView.vcDigit6.textField]
        accessoryView.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
        textFields.forEach({ $0.inputAccessoryView = accessoryView })
        configureTextFields()
        setupTargets()
        progressView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        textFields[0].becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.resignFirstResponder()
    }
    
    func configureTextFields() {
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
            contentView.resendVCButton.setTitle("Resend verification code »", for: .normal)
            contentView.resendVCButton.isUserInteractionEnabled = true
            timer.invalidate()
            seconds = 15
        } else {
            if seconds >= 10 {
                contentView.resendVCButton.setTitle("Resend code in: 0:\(seconds)", for: .normal)
            } else {
                contentView.resendVCButton.setTitle("Resend code in: 0:0\(seconds)", for: .normal)
            }
        }
    }
    
    @objc func resendVCButtonPressed(_ sender: Any) {
        contentView.resendVCButton.isUserInteractionEnabled = false
        resendVCAction()
    }
    
    func setupTargets() {
        accessoryView.nextButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
    }
    
    @objc func signIn() {
        var verificationCode : String = ""
        textFields.forEach { verificationCode.append($0.text!)}
        createCredential(verificationCode)
    }
    
    func textFieldController(current: UITextField, textFieldToChange: UITextField) {
        current.isEnabled = false
        textFieldToChange.isEnabled = true
    }
    
    func createCredential(_ verificationCode: String) {
        if verificationCode.count != 6 {
            return displayCredentialError()
        }
        guard let verificationId = UserDefaults.standard.value(forKey: Constants.VRFCTN_ID) as? String else {
            AlertController.genericErrorAlertWithoutCancel(self, title: "Unable to Authenticate", message: "We were unable to authenticate your phone number. Please try again.")
            return
        }
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: verificationCode)
        signInRegisterWithCredential(credential)
    }
    
    func displayCredentialError() {
        UIView.animate(withDuration: 0.5, animations: {
            for view in self.contentView.leftDigits.subviews + self.contentView.rightDigits.subviews {
                if view is RegistrationDigitTextField {
                    let digit = (view as! RegistrationDigitTextField)
                    digit.line.backgroundColor = .red
                }
            }
        }, completion: { (_: Bool) in
            UIView.animate(withDuration: 0.5, animations: {
                for view in self.contentView.leftDigits.subviews + self.contentView.rightDigits.subviews {
                    if view is RegistrationDigitTextField {
                        let digit = (view as! RegistrationDigitTextField)
                        
                        digit.line.backgroundColor = Colors.gray
                    }
                }
            }, completion: { (_: Bool) in
                for view in self.contentView.leftDigits.subviews + self.contentView.rightDigits.subviews {
                    if view is RegistrationDigitTextField {
                        let digit = (view as? RegistrationDigitTextField)
                        digit?.textField.fadeOut(withDuration: 0.3)
                        digit?.textField.alpha = 1.0
                    }
                }
            })
        })
    }
    
    func signInRegisterWithCredential(_ credential: PhoneAuthCredential) {
        displayLoadingOverlay()
        Auth.auth().signInAndRetrieveData(with: credential) { authResult, error in
            if error != nil {
                self.contentView.vcDigit6.textField.isEnabled = true
                self.displayCredentialError()
            } else {
                self.view.endEditing(true)
                guard let user = authResult?.user else { return }
                Database.database().reference().child("student-info").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists() {
                        UserDefaults.standard.set(true, forKey: "showHomePage")
                        if UserDefaults.standard.bool(forKey: "showHomePage") {
                            FirebaseData.manager.signInLearner(uid: user.uid) { successful in
                                if successful {
                                    Registration.setLearnerDefaults()
                                    RootControllerManager.shared.configureRootViewController(controller: LearnerMainPageVC())
                                } else {
                                    RootControllerManager.shared.configureRootViewController(controller: SignInVC())
                                }
                            }
                        } else {
                            FirebaseData.manager.signInTutor(uid: user.uid) { successful in
                                if successful {
                                    Registration.setTutorDefaults()
                                    self.navigationController?.pushViewController(QTTutorDashboardViewController.controller, animated: true)
                                } else {
                                    self.navigationController?.pushViewController(SignInVC(), animated: true)
                                }
                            }
                        }
                    } else {
                        Registration.uid = user.uid
                        AccountService.shared.currentUserType = .lRegistration
                        self.navigationController!.pushViewController(NameVC(), animated: true)
                    }
                })
            }
            self.dismissOverlay()
        }
    }
    
    func resendVCAction() {
        guard let phone = Registration.phone else { return }
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { verificationId, error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                self.contentView.resendVCButton.isUserInteractionEnabled = true
                return
            } else {
                self.runTimer()
                UserDefaults.standard.set(verificationId, forKey: Constants.VRFCTN_ID)
                UserDefaults.standard.synchronize()
            }
        }
    }
}

extension VerificationVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        let inverseSet = NSCharacterSet(charactersIn: "0123456789").inverted
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
            return (textFields[index].text == "") ? true : false
        }
        return false
    }
}
