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

class TutorSSNView : TutorRegistrationLayout, Keyboardable {
	
	var keyboardComponent = ViewComponent()
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
        addKeyboardView()
		digitView.addSubview(digit1)
		digitView.addSubview(digit2)
		digitView.addSubview(digit3)
		digitView.addSubview(digit4)
		super.configureView()
		
        progressBar.progress = 0.5
        progressBar.applyConstraints()
        
		title.label.text = "SSN"
		
		titleLabel.text = "For authentication purposes, we'll need the last 4 digits of your Social Security Number."
		titleLabel.numberOfLines = 0
		titleLabel.sizeToFit()
		titleLabel.font = Fonts.createBoldSize(18)
		titleLabel.textColor = .white
		
		ssnInfo.label.text = "· Your SSN remains private.\n· No credit check - credit won't be affected.\n· Your information is safe and secure."
		ssnInfo.label.font = Fonts.createSize(15)
		
		lockImageView.image = UIImage(named: "registration-ssn-lock")
		
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
	}
    
    func keyboardWillAppear() {
        if (digit1.textField.isFirstResponder) {
            if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
                ssnInfo.alpha = 0.0
            }
        
            needsUpdateConstraints()
            layoutIfNeeded()
        }
    }
    
    func keyboardWillDisappear() {
        if (digit4.textField.isFirstResponder) {
            if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
                    self.ssnInfo.alpha = 1.0
                })
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
	var index : Int = 0
	var textFields : [UITextField] = []
	var isValid : Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if (!(UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480)) {
            contentView.digit1.textField.becomeFirstResponder()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
		textFields = [contentView.digit1.textField, contentView.digit2.textField, contentView.digit3.textField, contentView.digit4.textField]
		configureTextFields()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		//TODO
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
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
	}
    
    @objc func keyboardWillAppear() {
        (self.view as! TutorSSNView).keyboardWillAppear()
    }
    
    @objc func keyboardWillDisappear() {
        (self.view as! TutorSSNView).keyboardWillDisappear()
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
			isValid = false
			return
		}
		guard let second = textFields[1].text, second != "" else {
			print("not valid")
			isValid = false

			return
		}
		guard let third = textFields[2].text, third != "" else {
			print("not valid")
			isValid = false

			return
		}
		guard let forth = textFields[3].text, forth != "" else {
			print("not valid")
			isValid = false
			return
		}
		isValid = true
		last4SSN = first + second + third + forth
	}
	
	private func textFieldController(current: UITextField, textFieldToChange: UITextField) {
		current.isEnabled = false
		textFieldToChange.isEnabled = true
	}
	
	override func handleNavigation() {
		if(touchStartView is NavbarButtonNext) {
			if isValid == true {
				TutorRegistration.last4SSN = last4SSN
				self.navigationController?.pushViewController(TutorRegPayment(), animated: true)
			} else {
				AlertController.genericErrorAlert(self, title: "Invalid SSN", message: nil)
			}
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

		
		guard let text = textField.text else { return true }
		let newLength = text.count + string.count - range.length

		if (index == 0) && (isBackSpace == Constants.BCK_SPACE) {
			textFields[index].text = ""
			last4SSN.removeLast()
			return true
		}

		if isBackSpace == Constants.BCK_SPACE {
			textFields[index].text = ""
			isValid = false
			textFieldController(current: textFields[index], textFieldToChange: textFields[index - 1])
			textFields[index - 1].becomeFirstResponder()
			index -= 1
			return false
		}
		
		if (index == 3) {
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
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return false
	}
}

