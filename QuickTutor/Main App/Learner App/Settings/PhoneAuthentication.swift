//
//  PhoneAuthentication.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

protocol AlertAction {
	func cancelAlertPressed()
	func verifyAlertPressed(code: String)
}

class PhoneAuthenicationAction : InteractableView, Interactable {
	
	let action : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createBoldSize(20)
		label.textColor = Colors.backgroundDark
		label.textAlignment = .center
		
		return label
	}()
	
	override func configureView() {
		addSubview(action)
		super.configureView()
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		action.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
	func touchStart() {
		alpha = 0.7
	}
	func didDragOff() {
		alpha = 1.0
	}
	func touchEndOnStart() {
		alpha = 1.0
	}
	func touchEndOffStart() {
		alpha = 1.0
	}
}
class PhoneAuthenicationActionCancel : InteractableView, Interactable {
	
	let cancel : UILabel = {
		let label = UILabel()
		label.text = "Cancel"
		label.font = Fonts.createBoldSize(20)
		label.textColor = Colors.backgroundDark
		label.textAlignment = .center
		
		return label
	}()
	
	override func configureView() {
		addSubview(cancel)
		super.configureView()
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		cancel.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
	func touchStart() {
		alpha = 0.7
	}
	func didDragOff() {
		alpha = 1.0
	}
	func touchEndOnStart() {
		alpha = 1.0
	}
	func touchEndOffStart() {
		alpha = 1.0
	}
}

class PhoneAuthenticationAlertView : InteractableView {
	
	var alertView : UIView = {
		let view = UIView()
		
		view.backgroundColor = UIColor.lightGray
		view.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.7, offset: CGSize(width: -2, height: 2), radius: 5)
		
		return view
	}()
	
	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Phone Verification"
		label.font = Fonts.createBoldSize(22)
		label.textColor = .black
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	let message : UILabel = {
		let label = UILabel()

		label.font = Fonts.createSize(16)
		label.textColor = .black
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = 3
		
		return label
	}()
	
	let errorLabel : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createSize(14)
		label.textColor = .red
		label.textAlignment = .center
		label.numberOfLines = 3
		label.adjustsFontSizeToFitWidth = true
		label.isHidden = true
		
		return label
	}()
	var cancelAction = PhoneAuthenicationActionCancel()
	var verifyAction = PhoneAuthenicationAction()
	
	let verificationTextField : NoPasteTextField = {
		let textField = NoPasteTextField()
		
		textField.text = "——————"
		textField.font = Fonts.createBoldSize(35)
		textField.textColor = .black
		textField.tintColor = .black
		textField.textAlignment = .center
		textField.adjustsFontSizeToFitWidth = true
		textField.keyboardType = .numberPad
		textField.keyboardAppearance = .dark
		
		return textField
	}()
	
	var delegate : AlertAction?
	
	override func configureView() {
		addSubview(alertView)
		alertView.addSubview(title)
		alertView.addSubview(message)
		alertView.addSubview(errorLabel)
		alertView.addSubview(cancelAction)
		alertView.addSubview(verifyAction)
		alertView.addSubview(verificationTextField)
		super.configureView()
		
		verifyAction.action.text = "Verify"
		self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
		verificationTextField.defaultTextAttributes.updateValue(10.0, forKey: NSAttributedStringKey.kern.rawValue)
		alpha = 0.0
		configureDelegates()
		applyConstraints()
	}
	
	override func applyConstraints() {
		alertView.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(0.8)
			make.height.equalToSuperview().multipliedBy(0.33)
			make.width.equalToSuperview().multipliedBy(0.85)
		}
		title.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalTo(40)
			make.top.equalToSuperview()
		}
		message.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalTo(60)
			make.top.equalTo(title.snp.bottom)
		}
		
		cancelAction.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalToSuperview().multipliedBy(0.25)
			make.left.equalToSuperview()
		}
		verifyAction.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalToSuperview().multipliedBy(0.25)
			make.right.equalToSuperview()
		}
		errorLabel.snp.makeConstraints { (make) in
			make.bottom.equalTo(cancelAction.snp.top)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalTo(30)
			make.centerX.equalToSuperview()
		}
		verificationTextField.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.9)
			make.top.equalTo(message.snp.bottom)
			make.bottom.equalTo(errorLabel.snp.top)
		}
	}
	override func layoutSubviews() {
		alertView.layer.cornerRadius = 10
		verifyAction.layer.addBorder(edge: .top, color: .black, thickness: 1.0)
		cancelAction.layer.addBorder(edge: .top, color: .black, thickness: 1.0)
		cancelAction.layer.addBorder(edge: .right, color: .black, thickness: 1.0)
	}
	
	private func configureDelegates() {
		verificationTextField.delegate = self
	}
}
extension PhoneAuthenticationAlertView : UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let inverseSet = NSCharacterSet(charactersIn:"0123456789_").inverted
		let components = string.components(separatedBy: inverseSet)
		let filtered = components.joined(separator: "")
		
		guard let text = textField.text else { return false }
		
		if string == filtered {
			if string == "" {
				guard let indexToReplace = text.index(text.startIndex, offsetBy: range.location, limitedBy: text.endIndex) else { return false }
				textField.text?.remove(at: indexToReplace)
				textField.text?.insert("—", at: indexToReplace)
				
				if let newPostion = textField.position(from: textField.beginningOfDocument, offset: range.location) {
					textField.selectedTextRange = textField.textRange(from: newPostion, to: newPostion)
					return false
				}
			}
			
			if range.location + 1 <= text.count,
				let end = text.index(text.startIndex, offsetBy: range.location + 1, limitedBy: text.endIndex),
				let start = text.index(text.startIndex, offsetBy: range.location, limitedBy: text.endIndex) {
				textField.text = textField.text?.replacingOccurrences(of: "—", with: string, options: .caseInsensitive, range: Range(uncheckedBounds: (lower: start, upper: end)))
				
			}
			if range.location + 1 < text.count {
				if let newPosition = textField.position(from: textField.beginningOfDocument, offset: range.location + 1){
					textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
				}
			}
		}
		return false
	}
	func textFieldDidBeginEditing(_ textField: UITextField) {
		let newPosition = textField.beginningOfDocument
		textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
	}
}
extension UIViewController {
	
	func displayPhoneVerificationAlert(message: String) {
		
		if let _ = self.view.viewWithTag(321)  {
			return
		}
		let alert = PhoneAuthenticationAlertView()
		alert.tag = 321
		alert.frame = self.view.bounds
		alert.message.text = message
		
		alert.growShrink()
		alert.verificationTextField.becomeFirstResponder()
		self.view.addSubview(alert)
	}
	
	func dismissPhoneAuthenticationAlert() {
		self.view.endEditing(true)
		if let alert = self.view.viewWithTag(321) {
			UIView.animate(withDuration: 0.2, animations: {
				alert.alpha = 0.0
				alert.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
			}) { _ in
				alert.removeFromSuperview()
			}
		}
	}
}
