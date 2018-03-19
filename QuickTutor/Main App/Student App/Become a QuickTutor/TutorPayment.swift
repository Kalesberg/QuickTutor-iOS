//
//  TutorPaymentInformation.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//
// 	BUG: -- Apple Developer docs state that keyboard type .NamePhonePad does not support Auto capitalization.
// 	So we may have to change it to a .default keyboard.

import UIKit
import SnapKit


class AddBankButton : InteractableView, Interactable {
    
    var label = UILabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        layer.cornerRadius = 6
        layer.borderWidth = 1.5
        layer.borderColor = Colors.green.cgColor
        
        label.textColor = Colors.green
        label.text = "Add Bank"
        label.textAlignment = .center
        label.font = Fonts.createSize(18)
        
        alpha = 0.5
		
		isUserInteractionEnabled = false
		
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func touchStart() {
        backgroundColor = Colors.registrationDark
    }
    
    func didDragOff() {
        backgroundColor = .clear
    }
}

class PaymentTextField : NoPasteTextField {
    
    override func configureTextField() {
        super.configureTextField()
        
        font = Fonts.createSize(15)
        textColor = Colors.grayText
        autocapitalizationType = .words
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = Colors.learnerPurple.cgColor
    }
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}

class TutorPaymentView : MainLayoutTitleBackButton, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    var contentView = UIView()
    var nameTitle = SectionTitle()
    var nameTextfield = PaymentTextField()
    var routingNumberTitle = SectionTitle()
	var routingNumberTextfield = PaymentTextField()
    var accountNumberTitle = SectionTitle()
	var accountNumberTextfield  = PaymentTextField()
    var addBankButton = AddBankButton()
    
	override func configureView() {
        addSubview(contentView)
        addSubview(addBankButton)
        contentView.addSubview(nameTitle)
        contentView.addSubview(nameTextfield)
        contentView.addSubview(routingNumberTitle)
        contentView.addSubview(routingNumberTextfield)
        contentView.addSubview(accountNumberTitle)
        contentView.addSubview(accountNumberTextfield)
        
        addKeyboardView()
		super.configureView()

        title.label.text = "Payment"
        
        nameTitle.label.text = "Name"
        routingNumberTitle.label.text = "Routing Number"
        accountNumberTitle.label.text = "Account Number"
		
        nameTextfield.attributedPlaceholder = NSAttributedString(string: "Enter bank holder's name", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        nameTextfield.keyboardType = .asciiCapable
		
        routingNumberTextfield.attributedPlaceholder = NSAttributedString(string: "Enter Routing Number", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        routingNumberTextfield.keyboardType = .decimalPad
        
        accountNumberTextfield.attributedPlaceholder = NSAttributedString(string: "Enter Account Number", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        accountNumberTextfield.keyboardType = .decimalPad
	}
    
	override func applyConstraints() {
		super.applyConstraints()
        
        addBankButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(keyboardView.snp.top).inset(-10)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.top.equalTo(navbar.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(addBankButton.snp.top)
        }
        
        nameTitle.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.18)
            make.centerX.equalToSuperview()
        }
		
        nameTextfield.snp.makeConstraints { (make) in
            make.top.equalTo(nameTitle.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        routingNumberTitle.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(nameTextfield.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.18)
        }
        
		routingNumberTextfield.snp.makeConstraints { (make) in
			make.top.equalTo(routingNumberTitle.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
		}
        
        accountNumberTitle.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(routingNumberTextfield.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.18)
        }
        
        accountNumberTextfield.snp.makeConstraints { (make) in
            make.top.equalTo(accountNumberTitle.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
	}
}

class TutorPayment: BaseViewController {
	
	override var contentView: TutorPaymentView {
		return view as! TutorPaymentView
	}
	override func loadView() {
		view = TutorPaymentView()
	}
	override func viewDidLoad() {
        super.viewDidLoad()
		
		let textFields = [contentView.nameTextfield, contentView.routingNumberTextfield, contentView.accountNumberTextfield]
		for textField in textFields{
			textField.delegate = self
			textField.returnKeyType = .next
			textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		}
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.nameTextfield.becomeFirstResponder()
	}
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		contentView.resignFirstResponder()
	}
	
    override func handleNavigation() {
        if (touchStartView is AddBankButton) {
            navigationController?.pushViewController(TutorSSN(), animated: true)
        }
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@objc private func textFieldDidChange(_ textField: UITextField) {
		
		contentView.addBankButton.isUserInteractionEnabled = false
		
		guard let name = contentView.nameTextfield.text, name.fullNameRegex() else {
			print("invalid name")
            contentView.addBankButton.alpha = 0.5
			return
		}
		print("Good Name")
		guard let routingNumber = contentView.routingNumberTextfield.text, routingNumber.count == 9 else {
			print("invalid routing")
            contentView.addBankButton.alpha = 0.5
			return
		}
		
		print("Good routing")
		guard let accountNumber = contentView.accountNumberTextfield.text, accountNumber.count > 5 else {
			print("invalid account")
            contentView.addBankButton.alpha = 0.5
			return
		}
		print("Good account.")
        
        contentView.addBankButton.alpha = 1.0
		contentView.addBankButton.isUserInteractionEnabled = true
		
		TutorRegistration.bankholderName = name
		TutorRegistration.routingNumber = routingNumber
		TutorRegistration.accountNumber = accountNumber
		
	}
	
}
extension TutorPayment : UITextFieldDelegate {
	
	internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField {
		case contentView.nameTextfield:
			contentView.routingNumberTextfield.becomeFirstResponder()
		case contentView.routingNumberTextfield:
			contentView.accountNumberTextfield.becomeFirstResponder()
		case contentView.accountNumberTextfield:
			resignFirstResponder()
		default:
			resignFirstResponder()
		}
		return true
	}
	internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
		let components = string.components(separatedBy: inverseSet)
		let filtered = components.joined(separator: "")
		
		guard let text = textField.text else { return true }
		let newLength = text.count + string.count - range.length


		switch textField {
		case contentView.nameTextfield:
			if string == "" { return true }
			if newLength <= 20 { return !(string == filtered) }
			return true
		case contentView.routingNumberTextfield:
			return (filtered == string)
		case contentView.accountNumberTextfield:
			return (filtered == string)
		default:
			return false
		}
	}
}
