//
//  EditBillingAddressVC.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit

class EditBillingAddressVC: BaseViewController {
	override var contentView: EditBillingAddressView {
		return view as! EditBillingAddressView
	}
	
	override func loadView() {
		view = EditBillingAddressView()
	}
	
	private var textFields: [UITextField] = []
	private var addressString = ""
	private var validData: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		hideKeyboardWhenTappedAround()
		textFields = [contentView.addressLine1TextField, contentView.cityTextField, contentView.stateTextField, contentView.zipTextField]
		
		for textField in textFields {
			textField.delegate = self
			textField.returnKeyType = .next
			textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		}
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
	
	@objc private func textFieldDidChange(_: UITextField) {
		guard let line1 = textFields[0].text, line1.streetRegex() else {
			textFields[0].layer.borderColor = Colors.qtRed.cgColor
			validData = false
			return
		}
		textFields[0].layer.borderColor = Colors.green.cgColor
		
		guard let city = textFields[1].text, city.cityRegex() else {
			textFields[1].layer.borderColor = Colors.qtRed.cgColor
			validData = false
			return
		}
		textFields[1].layer.borderColor = Colors.green.cgColor
		
		guard let state = textFields[2].text, state.stateRegex() else {
			textFields[2].layer.borderColor = Colors.qtRed.cgColor
			validData = false
			return
		}
		textFields[2].layer.borderColor = Colors.green.cgColor
		
		guard let zipcode = textFields[3].text, zipcode.zipcodeRegex() else {
			textFields[3].layer.borderColor = Colors.qtRed.cgColor
			validData = false
			return
		}
		textFields[3].layer.borderColor = Colors.green.cgColor
		addressString = line1 + " " + city + " " + state + ", " + zipcode
		validData = true
	}
	
	override func handleNavigation() {
		if touchStartView is NavbarButtonNext {
			contentView.rightButton.isUserInteractionEnabled = false
			if validData {
				
			}
		} else {
			contentView.rightButton.isUserInteractionEnabled = true
		}
	}
}

extension EditBillingAddressVC: UITextFieldDelegate {
	internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let inverseSet = NSCharacterSet(charactersIn: "0123456789-").inverted
		let components = string.components(separatedBy: inverseSet)
		let filtered = components.joined(separator: "")
		
		guard let text = textField.text else { return true }
		let newLength = text.count + string.count - range.length
		
		switch textField {
		case textFields[0]:
			if newLength < 30 {
				return true
			}
			return false
		case textFields[1]:
			if string == "" { return true }
			return !(string == filtered)
		case textFields[2]:
			if string == "" { return true }
			if newLength > 2 {
				return false
			} else {
				return !(string == filtered)
			}
		case textFields[3]:
			if newLength <= 10 {
				return string == filtered
			}
			return false
		default:
			break
		}
		return false
	}
	
	internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField {
		case textFields[0]:
			textFields[1].becomeFirstResponder()
		case textFields[1]:
			textFields[2].becomeFirstResponder()
		case textFields[2]:
			textFields[3].becomeFirstResponder()
		default:
			break
		}
		return false
	}
}
