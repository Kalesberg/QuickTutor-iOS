//
//  TutorAddress.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/20/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit
import SnapKit


fileprivate class AddressTextField : NoPasteTextField {
	
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

class TutorAddressView : TutorRegistrationLayout, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	var contentView = UIView()
	
	var addressLine1Title = SectionTitle()
	fileprivate var addressLine1TextField = AddressTextField()
	
	var cityTitle = SectionTitle()
	fileprivate var cityTextField = AddressTextField()
	
	var stateTitle = SectionTitle()
	fileprivate var stateTextField  = AddressTextField()
	
	var zipTitle = SectionTitle()
	fileprivate var zipTextField = AddressTextField()
	
	override func configureView() {
		addSubview(contentView)
		contentView.addSubview(addressLine1Title)
		contentView.addSubview(addressLine1TextField)
		contentView.addSubview(cityTitle)
		contentView.addSubview(cityTextField)
		contentView.addSubview(stateTitle)
		contentView.addSubview(stateTextField)
		contentView.addSubview(zipTitle)
		contentView.addSubview(zipTextField)
		
		addKeyboardView()
		super.configureView()
		
		title.label.text = "Billing Address"
        
        progressBar.progress = 0.8333333
        progressBar.applyConstraints()
		
		addressLine1Title.label.text = "Address"
		cityTitle.label.text = "City"
		stateTitle.label.text = "State"
		zipTitle.label.text = "Postal Code"
		
		
		addressLine1TextField.attributedPlaceholder = NSAttributedString(string: "Enter Billing Address", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		addressLine1TextField.keyboardType = .asciiCapable
		
		cityTextField.attributedPlaceholder = NSAttributedString(string: "Enter City", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		cityTextField.keyboardType = .asciiCapable
		
		stateTextField.attributedPlaceholder = NSAttributedString(string: "Enter State", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		stateTextField.keyboardType = .asciiCapable
		stateTextField.autocapitalizationType = .allCharacters
		
		zipTextField.attributedPlaceholder = NSAttributedString(string: "Enter Postal Code", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		zipTextField.keyboardType = .decimalPad
		
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		contentView.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.85)
			make.top.equalTo(navbar.snp.bottom)
			make.centerX.equalToSuperview()
			make.bottom.equalTo(keyboardView.snp.top)
		}
		
		addressLine1Title.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.18)
			make.centerX.equalToSuperview()
		}
		
		addressLine1TextField.snp.makeConstraints { (make) in
			make.top.equalTo(addressLine1Title.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		
		cityTitle.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.top.equalTo(addressLine1TextField.snp.bottom)
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.18)
		}
		
		cityTextField.snp.makeConstraints { (make) in
			make.top.equalTo(cityTitle.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		
		stateTitle.snp.makeConstraints { (make) in
			make.width.equalToSuperview().dividedBy(2)
			make.top.equalTo(cityTextField.snp.bottom)
			make.left.equalTo(cityTitle.snp.left)
			make.height.equalToSuperview().multipliedBy(0.18)
		}
		
		stateTextField.snp.makeConstraints { (make) in
			make.top.equalTo(stateTitle.snp.bottom)
			make.width.equalToSuperview().dividedBy(2)
			make.left.equalTo(cityTextField.snp.left)
			make.height.equalTo(30)
		}
		zipTitle.snp.makeConstraints { (make) in
			make.width.equalToSuperview().dividedBy(2)
			make.top.equalTo(cityTextField.snp.bottom)
			make.right.equalTo(cityTitle.snp.right)
			make.height.equalToSuperview().multipliedBy(0.18)
		}
		
		zipTextField.snp.makeConstraints { (make) in
			make.top.equalTo(zipTitle.snp.bottom)
			make.width.equalToSuperview().dividedBy(2)
			make.right.equalTo(cityTextField.snp.right)
			make.height.equalTo(30)
		}
	}
}

class TutorAddress : BaseViewController {
	
	override var contentView: TutorAddressView {
		return view as! TutorAddressView
	}
	override func loadView() {
		view = TutorAddressView()
	}
	
	private var textFields : [UITextField] = []
	private var addressString = ""
	private var validData : Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		textFields = [contentView.addressLine1TextField, contentView.cityTextField, contentView.stateTextField, contentView.zipTextField]
		
		for textField in textFields{
			textField.delegate = self
			textField.returnKeyType = .next
			textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.nextButton.isUserInteractionEnabled = true
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		contentView.resignFirstResponder()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@objc private func textFieldDidChange(_ textField: UITextField) {
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
		if (touchStartView is NavbarButtonNext) {
            contentView.rightButton.isUserInteractionEnabled = false
            if validData {
				self.displayLoadingOverlay()
                TutorLocation.convertAddressToLatLong(addressString: addressString) { (error) in
                    if error != nil {
						AlertController.genericErrorAlert(self, title: "Unable to Find Address", message: "Please make sure your information is correct.")
                        self.contentView.rightButton.isUserInteractionEnabled = true
                    } else {
                        self.navigationController?.pushViewController(TutorAddUsername(), animated: true)
                    }
					self.dismissOverlay()
                }
            } else {
                contentView.rightButton.isUserInteractionEnabled = true
				print("fill out the correct information.")
            }
		}
	}
}

extension TutorAddress : UITextFieldDelegate {
	
	internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let inverseSet = NSCharacterSet(charactersIn:"0123456789-").inverted
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
