//
//  EditPhoneVerification.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import FirebaseAuth
import FirebaseDatabase

class EditPhoneVerificationView : MainLayoutTitleBackButton, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	
	var subtitle = LeftTextLabel()
	
	var vcDigit1         = RegistrationDigitTextField()
	var vcDigit2         = RegistrationDigitTextField()
	var vcDigit3         = RegistrationDigitTextField()
	var vcDigit4         = RegistrationDigitTextField()
	var vcDigit5         = RegistrationDigitTextField()
	var vcDigit6         = RegistrationDigitTextField()
	
	var digitView        = UIView()
	var leftDigits       = UIView()
	var rightDigits      = UIView()
	var resendVCButton   = UIButton()
	var updateButton  	 = UpdateButton()
	
	override func configureView() {
		
		addSubview(leftDigits)
		
		leftDigits.addSubview(vcDigit1)
		leftDigits.addSubview(vcDigit2)
		leftDigits.addSubview(vcDigit3)
		
		addSubview(rightDigits)
		rightDigits.addSubview(vcDigit4)
		rightDigits.addSubview(vcDigit5)
		rightDigits.addSubview(vcDigit6)
		
		addSubview(digitView)
		digitView.addSubview(leftDigits)
		digitView.addSubview(rightDigits)
		addSubview(subtitle)

		addSubview(resendVCButton)
		
		addSubview(updateButton)
		
		addKeyboardView()
		super.configureView()
		
		title.label.text = "Verify Phone Number"
		
		subtitle.label.font = Fonts.createBoldSize(18)
		subtitle.label.numberOfLines = 2

		resendVCButton.setTitle("Resend Code", for: .normal)
		resendVCButton.titleLabel?.font = Fonts.createSize(18)
		resendVCButton.setTitleColor(UIColor(red: 0.4469467998, green: 0.3617748618, blue: 0.657984674, alpha: 1), for: .normal)
		
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		subtitle.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview().multipliedBy(0.55)
			make.width.equalToSuperview().multipliedBy(0.85)
			make.centerX.equalToSuperview()
			make.height.equalTo(60) //a default textfield is 30. So, 60 accounts for the second line.
		}
		
		digitView.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview().multipliedBy(0.85)
			make.height.equalToSuperview().multipliedBy(0.3)
			make.width.equalToSuperview().multipliedBy(0.7)
			make.centerX.equalToSuperview()
		}
		leftDigits.snp.makeConstraints { (make) in
			make.top.equalToSuperview().multipliedBy(1.1)
			make.height.equalToSuperview().multipliedBy(0.7)
			make.left.equalToSuperview().offset(-5)
			make.width.equalToSuperview().multipliedBy(0.5)
		}
		
		rightDigits.snp.makeConstraints { (make) in
			make.top.equalToSuperview().multipliedBy(1.1)
			make.height.equalToSuperview().multipliedBy(0.7)
			make.right.equalToSuperview().offset(5)
			make.width.equalToSuperview().multipliedBy(0.5)
		}
		
		vcDigit1.applyConstraint(rightMultiplier: 0.33333)
		vcDigit2.applyConstraint(rightMultiplier: 0.66666)
		vcDigit3.applyConstraint(rightMultiplier: 1.0)
		vcDigit4.applyConstraint(rightMultiplier: 0.33333)
		vcDigit5.applyConstraint(rightMultiplier: 0.66666)
		vcDigit6.applyConstraint(rightMultiplier: 1.0)
		
		resendVCButton.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.left.equalTo(subtitle.snp.left)
		}
		updateButton.snp.makeConstraints { (make) in
			make.bottom.equalTo(keyboardView.snp.top)
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.08)
			make.centerX.equalToSuperview()
		}
	}
}
class UpdateButton : InteractableView, Interactable {
	
	var title = UILabel()
	
	override func configureView(){
		addSubview(title)
		super.configureView()
		
		isUserInteractionEnabled = true
		
		title.text = "Update Phone"
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

class EditPhoneVerification : BaseViewController {
	
	override var contentView: EditPhoneVerificationView {
		return view as! EditPhoneVerificationView
	}
	
	override func loadView() {
		view = EditPhoneVerificationView()
	}
	
	private var ref: DatabaseReference!
	private var verificationCode = ""
	private var index : Int = 0
	private var textFields : [UITextField] = []
	
	static var phoneNumber : String!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		ref = Database.database().reference(fromURL: Constants.DATABASE_URL)
		
		textFields = [contentView.vcDigit1.textField, contentView.vcDigit2.textField, contentView.vcDigit3.textField, contentView.vcDigit4.textField, contentView.vcDigit5.textField, contentView.vcDigit6.textField]
		configureTextFields()
	}
	override func viewDidAppear(_ animated: Bool) {
		textFields[0].becomeFirstResponder()
	}
	override func viewWillDisappear(_ animated: Bool) {
		contentView.resignFirstResponder()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		contentView.subtitle.label.text = "Enter the 6-digit code sent to you at:\n\(EditPhoneVerification.phoneNumber!)"
		contentView.updateButton.isUserInteractionEnabled = false
	}
	private func configureTextFields() {
		for textField in textFields {
			textField.isEnabled = false
			textField.tintColor = .clear
			textField.delegate = self
			textField.addTarget(self, action: #selector(buildVerificationCode(_:)), for: .editingChanged)
		}
		contentView.vcDigit1.textField.isEnabled = true
	}
	
	@objc private func buildVerificationCode(_ textField: UITextField) {
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
		contentView.updateButton.isUserInteractionEnabled = true
	}
	override func handleNavigation() {
		if touchStartView == contentView.resendVCButton {
			resendVCAction()
		} else if touchStartView == contentView.updateButton {
			createCredential(verificationCode)
		}
	}
	
	private func textFieldController(current: UITextField, textFieldToChange: UITextField) {
		current.isEnabled = false
		textFieldToChange.isEnabled = true
	}
	
//	@objc
//	private func buildVerificationCode(_ textField: UITextField) {
//		verificationCode.append(textField.text!)
//	}
//
	private func createCredential(_ verificationCode: String) {
		if (verificationCode.count == 6) {
			let verificationId = UserDefaults.standard.value(forKey: "reCredential")
			let credential : PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId! as! String, verificationCode: verificationCode)
			updatePhoneNumber(credential)
		}
	}
	
	private func updatePhoneNumber(_ credential: PhoneAuthCredential) {
		Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { (error) in
			if let error = error {
				print(error.localizedDescription)
			} else{
				LearnerData.userData.phone = EditPhoneVerification.phoneNumber
				FirebaseData.manager.updateValue(value: ["phn": LearnerData.userData.phone.cleanPhoneNumber()])
				self.navigationController?.popToViewController(EditProfile(), animated: true)
			}
		})
	}

	private func resendVCAction() {
		PhoneAuthProvider.provider().verifyPhoneNumber(EditPhoneVerification.phoneNumber.cleanPhoneNumber(), uiDelegate: nil) { (verificationId, error) in
			if let error = error {
				print("Error: ", error.localizedDescription)
				return
			}else{
				UserDefaults.standard.set(verificationId, forKey: Constants.VRFCTN_ID)
			}
		}
	}
}

extension EditPhoneVerification : UITextFieldDelegate {
	
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
			contentView.updateButton.isUserInteractionEnabled = false
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

