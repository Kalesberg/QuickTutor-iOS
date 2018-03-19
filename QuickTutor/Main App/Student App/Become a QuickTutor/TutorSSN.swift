//
//  TutorSSN.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit

class SSNDigitTextField : RegistrationDigitTextField {
	
	override func applyConstraint(rightMultiplier: ConstraintMultiplierTarget) {
		self.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.height.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.25)
			make.right.equalToSuperview().multipliedBy(rightMultiplier)
		}
		
		textField.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.85)
			make.centerX.equalToSuperview()
		}
		
		line.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.85)
			make.height.equalTo(1)
			make.centerY.equalToSuperview().multipliedBy(1.5)
			make.centerX.equalToSuperview()
		}
	}
}

class TutorSSNView : MainLayoutTitleBackButton, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	var nextButton        = RegistrationNextButton()
	var titleLabel        = UILabel()
	
	var digitView         = UIView()
	
	var digit1            = SSNDigitTextField()
	var digit2            = SSNDigitTextField()
	var digit3            = SSNDigitTextField()
	var digit4            = SSNDigitTextField()
	
	var lockImageView     = UIImageView()
	var ssnInfo           = LeftTextLabel()
	
	override func configureView() {
		addSubview(titleLabel)
		addSubview(digitView)
		addSubview(ssnInfo)
		addSubview(nextButton)
        addKeyboardView()
		digitView.addSubview(digit1)
		digitView.addSubview(digit2)
		digitView.addSubview(digit3)
		digitView.addSubview(digit4)
		super.configureView()
		
		title.label.text = "SSN"
		
		titleLabel.text = "For authentication purposes, we'll need the last 4 digits of your Social Security Number."
		titleLabel.numberOfLines = 0
		titleLabel.sizeToFit()
		titleLabel.font = Fonts.createBoldSize(18)
		titleLabel.textColor = .white
		
		ssnInfo.label.text = "· Your SSN remains private.\n· No credit check - credit won't be affected.\n· Your information is safe and secure."
		ssnInfo.label.font = Fonts.createSize(15)
		
		lockImageView.image = UIImage(named: "registration-ssn-lock")
		
		nextButton.isUserInteractionEnabled = false
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		titleLabel.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.85)
			make.top.equalTo(navbar.snp.bottom).inset(-35)
			make.centerX.equalToSuperview()
		}
		
		digitView.snp.makeConstraints { (make) in
			make.width.equalTo(250)
			make.height.equalToSuperview().multipliedBy(0.15)
			make.centerX.equalToSuperview()
			make.top.equalTo(titleLabel.snp.bottom)
		}
		
		digit1.applyConstraint(rightMultiplier: 0.25)
		digit2.applyConstraint(rightMultiplier: 0.5)
		digit3.applyConstraint(rightMultiplier: 0.75)
		digit4.applyConstraint(rightMultiplier: 1.0)
		
		ssnInfo.snp.makeConstraints { (make) in
			make.top.equalTo(digitView.snp.bottom).inset(-30)
			make.width.equalTo(titleLabel)
			make.centerX.equalToSuperview()
		}
		
        nextButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(20)
            make.width.equalToSuperview()
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
        }
	}
    
    func keyboardWillAppear() {
        if (digit1.textField.isFirstResponder) {
            if (UIScreen.main.bounds.height == 568) {
                ssnInfo.alpha = 0.0
            }
        
            nextButton.snp.removeConstraints()
            nextButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(keyboardView.snp.top)
                make.width.equalToSuperview()
                make.height.equalTo(60)
                make.centerX.equalToSuperview()
            }
        
            needsUpdateConstraints()
            layoutIfNeeded()
        }
    }
    
    func keyboardWillDisappear() {
        if (digit4.textField.isFirstResponder) {
            if (UIScreen.main.bounds.height == 568) {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
                    self.ssnInfo.alpha = 1.0
                })
            }
            
            nextButton.snp.removeConstraints()
            nextButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(20)
                make.width.equalToSuperview()
                make.height.equalTo(60)
                make.centerX.equalToSuperview()
            }
            
            needsUpdateConstraints()
            
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            })
        }
    }
}


class TutorSSN : BaseViewController {
	
	override var contentView: TutorSSNView {
		return view as! TutorSSNView
	}
	override func loadView() {
		view = TutorSSNView()
	}
	var last4SSN : String = ""
	override func viewDidLoad() {
		super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
		let textFields = [contentView.digit1.textField, contentView.digit2.textField, contentView.digit3.textField, contentView.digit4.textField]
		for textField in textFields {
			textField.delegate = self
			textField.addTarget(self, action: #selector(buildVerificationCode(_:)), for: .editingChanged)
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		contentView.resignFirstResponder()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    @objc func keyboardWillAppear() {
        (self.view as! TutorSSNView).keyboardWillAppear()
    }
    
    @objc func keyboardWillDisappear() {
        (self.view as! TutorSSNView).keyboardWillDisappear()
    }
	
	override func handleNavigation() {
		if(touchStartView is RegistrationNextButton) {
			TutorRegistration.last4SSN = last4SSN
			navigationController?.pushViewController(TutorAddSubjects(), animated: true)
		}
	}
	private func textFieldController(current: UITextField, textFieldToChange: UITextField) {
		current.isEnabled = false
		textFieldToChange.isEnabled = true
	}
	
	//going to fix this...
	@objc
	private func buildVerificationCode(_ textField: UITextField) {
		last4SSN.append(textField.text!)
		if (last4SSN.count == 4) {
			contentView.nextButton.isUserInteractionEnabled = true
		} else {
			contentView.nextButton.isUserInteractionEnabled = false
		}
	}
}

extension TutorSSN : UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let char = string.cString(using: String.Encoding.utf8)!
		let isBackSpace = strcmp(char, "\\b")
		
		let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
		let components = string.components(separatedBy: inverseSet)
		let filtered = components.joined(separator: "")
		
		if textField.text!.count == 1 {
			
			switch(textField) {
			case contentView.digit1.textField:
				if (isBackSpace == Constants.BCK_SPACE){
					contentView.digit1.textField.text = ""
					self.last4SSN.removeLast()
					return false
				}else{
					textFieldController(current: contentView.digit1.textField, textFieldToChange: contentView.digit2.textField)
					contentView.digit2.textField.becomeFirstResponder()
					return true
				}
			case contentView.digit2.textField:
				if(isBackSpace == Constants.BCK_SPACE){
					contentView.digit2.textField.text = ""
					textFieldController(current: contentView.digit2.textField, textFieldToChange: contentView.digit1.textField)
					contentView.digit1.textField.becomeFirstResponder()
					self.last4SSN.removeLast()
					return false
				}else{
					textFieldController(current: contentView.digit2.textField, textFieldToChange: contentView.digit3.textField)
					contentView.digit3.textField.becomeFirstResponder()
					return true
				}
			case contentView.digit3.textField:
				if(isBackSpace == Constants.BCK_SPACE) {
					contentView.digit3.textField.text = ""
					textFieldController(current: contentView.digit3.textField, textFieldToChange: contentView.digit2.textField)
					contentView.digit2.textField.becomeFirstResponder()
					self.last4SSN.removeLast()
					return false
				}else{
					textFieldController(current: contentView.digit3.textField, textFieldToChange: contentView.digit4.textField)
					contentView.digit4.textField.becomeFirstResponder()
					return true
				}
			case contentView.digit4.textField:
				if (isBackSpace == Constants.BCK_SPACE){
					contentView.digit4.textField.text = ""
					textFieldController(current: contentView.digit4.textField, textFieldToChange: contentView.digit3.textField)
					contentView.digit3.textField.becomeFirstResponder()
					self.last4SSN.removeLast()
					return false
				} else {
					return false
				}
			default:
				contentView.digit4.textField.becomeFirstResponder()
				return false
			}
		}
		return string == filtered
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return false
	}
}

