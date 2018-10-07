//
//  Email.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth

class EmailView: RegistrationNavBarKeyboardView {
    
	let emailTextField : RegistrationTextField = {
		let registrationTextField = RegistrationTextField()
		registrationTextField.placeholder.text = "EMAIL"
		registrationTextField.textField.returnKeyType = .next
		registrationTextField.textField.keyboardType = .emailAddress
		registrationTextField.textField.autocapitalizationType = .none
		return registrationTextField
	}()
	let checkboxLabel : LeftTextLabel = {
		let leftTextLabel = LeftTextLabel()
		leftTextLabel.label.font = Fonts.createLightSize(14.5)
		leftTextLabel.label.text = "I'd like to recieve promotional content, including events, surveys, motivation, in-app reminders, and goodies from QuickTutor via email."
		leftTextLabel.label.adjustsFontSizeToFitWidth = true

		return leftTextLabel
	}()
	
	let checkbox = RegistrationCheckbox()
    
    override func configureView() {
        super.configureView()
        contentView.addSubview(emailTextField)
        contentView.addSubview(checkboxLabel)
        contentView.addSubview(checkbox)
        
        progressBar.progress = 0.4
        progressBar.applyConstraints()
        
        titleLabel.label.text = "Your Email?"

        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        emailTextField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.47)
            make.right.equalToSuperview()
            make.left.equalToSuperview()
        }
        checkboxLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.left.equalToSuperview()
        }
        checkbox.snp.makeConstraints { make in
            make.top.equalTo(checkboxLabel).inset(10)
            make.bottom.equalTo(checkboxLabel).inset(10)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.left.equalTo(checkboxLabel.snp.right)
        }
    }
}

class EmailVC: BaseViewController {
    
    override var contentView: EmailView {
        return view as! EmailView
    }
    
    override func loadView() {
        view = EmailView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.emailTextField.textField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.emailTextField.textField.becomeFirstResponder()
    }
    private func nextButtonPress() {
        if (contentView.emailTextField.textField.text!).emailRegex() {
            displayLoadingOverlay()
            Auth.auth().fetchProviders(forEmail: contentView.emailTextField.textField.text!, completion: { response, error in
                if let error = error {
                    print(error.localizedDescription)
                    self.dismissOverlay()
                } else {
                    if response == nil {
                        self.dismissOverlay()
                        self.contentView.errorLabel.isHidden = true
                        Registration.email = self.contentView.emailTextField.textField.text!
                        self.navigationController?.pushViewController(CreatePasswordVC(), animated: true)
                    } else {
                        self.dismissOverlay()
                        self.contentView.errorLabel.isHidden = false
                        self.contentView.errorLabel.text = "Email already in use."
                    }
                }
            })
        } else {
            contentView.errorLabel.isHidden = false
            contentView.errorLabel.text = "The provided Email is not valid"
        }
    }
    
    override func handleNavigation() {
        if touchStartView == contentView.backButton {
            navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
            navigationController!.popViewController(animated: false)
            
        } else if touchStartView == contentView.nextButton {
            nextButtonPress()
        }
    }
    private func keyboardNextWasPressed() {
        nextButtonPress()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension EmailVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxlength = 40
        guard let text = textField.text else { return true }
        let length = text.count + string.count - range.length
        
        if length <= maxlength { return true }
        else { return false }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case contentView.emailTextField.textField:
            keyboardNextWasPressed()
            return false
        default:
            contentView.emailTextField.textField.becomeFirstResponder()
            return false
        }
    }
}
