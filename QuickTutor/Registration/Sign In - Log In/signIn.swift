//
//  signIn.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/16/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//
//TODO: Design
//
//TODO: Backend
// 	- Add hyperlinks to infoLabel for the policies
//	- Anyway to use the functionality of FBSDKLoginButton for our custom button? maybe override it, remove views, add our own?? lemme know
//	- Next button only interactable if a valid phone number is typed in

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import SnapKit


class SignInView: RegistrationGradientView, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	
	var backButton = RegistrationBackButton()
	var nextButton = RegistrationNextButton()
	
	var phoneNumberTextField = RegistrationTextField()
	var signInButton         = RegistrationNextButton()
	var facebookButton       = FBSDKLoginButton()
	var signinLabel          = UILabel()
	
	var quicktutorText = UIImageView()
	var learnAnythingLabel = CenterTextLabel()
	var quicktutorFlame = UIImageView()
	
	var numberLabel = LeftTextLabel()
	
	var container = UIView()
	var phoneTextField = PhoneTextField()
	var facebookButton2 = FacebookButton()
	
	var infoLabel = UILabel()
	
	override func configureView() {
		addKeyboardView()
		addSubview(backButton)
		addSubview(nextButton)
		addSubview(quicktutorText)
		addSubview(learnAnythingLabel)
		addSubview(quicktutorFlame)
		addSubview(infoLabel)
		addSubview(container)
		container.addSubview(phoneTextField)
		phoneTextField.addSubview(numberLabel)
		container.addSubview(facebookButton2)
		super.configureView()
	
		backButton.alpha = 0.0
		backButton.isUserInteractionEnabled = false
		
		nextButton.alpha = 0.0
		nextButton.isUserInteractionEnabled = false
		
		quicktutorText.image = UIImage(named: "quicktutor-text")
		
		learnAnythingLabel.label.text = "learn anything | teach anyone"
		learnAnythingLabel.label.font = Fonts.createLightSize(20)
		
		infoLabel.text = "By tapping continue or entering a mobile phone number, I agree to QuickTutor's Terms of Service, Privacy Policy, and Nondiscrimination Policy."
		infoLabel.font = Fonts.createLightSize(14)
		infoLabel.textColor = .white
		infoLabel.textAlignment = .left
		infoLabel.numberOfLines = 0
		infoLabel.sizeToFit()
		
		quicktutorFlame.image = UIImage(named: "qt-flame")
		
		numberLabel.label.text = "YOUR MOBILE NUMBER"
		numberLabel.label.font = Fonts.createBoldSize(14)
		
		phoneTextField.textField.isEnabled = false
		phoneTextField.textField.keyboardType = .numberPad

//		phoneNumberTextField.textField.keyboardType = .numberPad
//
//		facebookButton.setTitle("Log in with facebook", for: .normal)
//		signinLabel.text = "Sign in Screen..."
//		facebookButton.backgroundColor = UIColor.blue
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		backButton.snp.makeConstraints { (make) in
			make.top.equalTo(safeAreaLayoutGuide.snp.top)
			make.width.equalToSuperview().multipliedBy(0.25)
			make.height.equalToSuperview().multipliedBy(0.13)
			make.left.equalToSuperview()
		}
		
		nextButton.snp.makeConstraints { (make) in
			make.bottom.equalTo(keyboardView.snp.top)
			make.right.equalToSuperview().inset(15)
			make.width.equalToSuperview().multipliedBy(0.25)
			make.height.equalToSuperview().multipliedBy(0.1)
		}
		
		quicktutorText.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(20)
		}
		
		learnAnythingLabel.snp.makeConstraints { (make) in
			make.top.equalTo(quicktutorText.snp.bottom)
			make.height.equalTo(30)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
		
		quicktutorFlame.snp.makeConstraints { (make) in
			make.top.equalTo(learnAnythingLabel.snp.bottom).offset(30)
			make.centerX.equalToSuperview()
		}
		
		infoLabel.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.8)
			make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(15)
			make.centerX.equalToSuperview()
		}
		
		container.snp.makeConstraints { (make) in
			make.top.equalTo(quicktutorFlame.snp.bottom)
			make.bottom.equalTo(infoLabel.snp.top)
			make.width.equalToSuperview().multipliedBy(0.8)
			make.centerX.equalToSuperview()
		}
		
		phoneTextField.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(0.7)
			make.height.equalTo(60)
			make.centerX.equalToSuperview()
		}
		
		numberLabel.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		
		facebookButton2.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview().multipliedBy(1.5)
			make.height.equalTo(30)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
}


class FacebookButton : InteractableView, Interactable {
	
	var facebookIcon = UIImageView()
	var facebookLabel = LeftTextLabel()
	
	override func configureView() {
		addSubview(facebookIcon)
		addSubview(facebookLabel)
		super.configureView()
		
		facebookIcon.image = UIImage(named: "fb-signin")
		
		facebookLabel.label.text = "Continue with Facebook »"
		facebookLabel.label.font = Fonts.createSize(18)
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		facebookIcon.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		
		facebookLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(30)
			make.right.equalToSuperview()
			make.centerY.equalToSuperview()
			make.height.equalTo(30)
		}
	}
}


class SignIn: BaseViewController {
	
	var verificationId : String!
	
	override var contentView: SignInView {
		return view as! SignInView
	}
	
	override func loadView() {
		view = SignInView()
	}
	
	let fbLoginManager = FBSDKLoginManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		fbLoginManager.logOut()
		contentView.phoneTextField.textField.delegate = self
	}

	override func viewDidAppear(_ animated: Bool) {
		//contentView.phoneNumberTextField.textField.becomeFirstResponder()
		//contentView.signInButton.isUserInteractionEnabled = true
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func handleNavigation() {
		if (touchStartView is PhoneTextField) {
			contentView.quicktutorText.fadeOut(withDuration: 0.2)
			contentView.learnAnythingLabel.fadeOut(withDuration: 0.2)
			contentView.facebookButton2.fadeOut(withDuration: 0.2)
			contentView.infoLabel.fadeOut(withDuration: 0.2)
			
			contentView.phoneTextField.snp.remakeConstraints({ (make) in
				make.top.equalTo(self.contentView.backButton.snp.bottom)
				make.width.equalToSuperview()
				make.centerX.equalToSuperview()
				make.height.equalTo(60)
			})
			
			contentView.quicktutorFlame.snp.remakeConstraints({ (make) in
				make.centerX.equalToSuperview()
				make.top.equalTo(contentView.phoneTextField.snp.bottom).offset(30)
			})
			
			contentView.setNeedsUpdateConstraints()
			UIView.animate(withDuration: 0.7, delay: 0.2, options: .curveEaseIn, animations: {
				self.contentView.layoutIfNeeded()
			}, completion: { (true) in
				self.contentView.backButton.fadeIn(withDuration: 0.2, alpha: 1.0)
				self.contentView.backButton.isUserInteractionEnabled = true
				self.contentView.phoneTextField.textField.isEnabled = true
				self.contentView.phoneTextField.textField.becomeFirstResponder()
				self.contentView.nextButton.fadeIn(withDuration: 0.2, alpha: 1.0)
				self.contentView.nextButton.isUserInteractionEnabled = true
			})
		} else if(touchStartView is RegistrationBackButton) {
			contentView.backButton.isUserInteractionEnabled = false
			contentView.nextButton.isUserInteractionEnabled = false
			contentView.phoneTextField.textField.isEnabled = false
			contentView.backButton.fadeOut(withDuration: 0.2)
			contentView.nextButton.fadeOut(withDuration: 0.2)
			
			contentView.phoneTextField.snp.removeConstraints()
			contentView.quicktutorFlame.snp.removeConstraints()
			
			contentView.phoneTextField.snp.remakeConstraints { (make) in
				make.width.equalToSuperview()
				make.centerY.equalToSuperview().multipliedBy(0.7)
				make.height.equalTo(60)
				make.centerX.equalToSuperview()
			}
			
			contentView.quicktutorFlame.snp.remakeConstraints { (make) in
				make.top.equalTo(contentView.learnAnythingLabel.snp.bottom).offset(30)
				make.centerX.equalToSuperview()
			}
			
			contentView.setNeedsUpdateConstraints()
			UIView.animate(withDuration: 0.7, delay: 0.2, options: .curveEaseIn, animations: {
				self.contentView.layoutIfNeeded()
			}, completion: { (true) in
				self.contentView.quicktutorText.fadeIn(withDuration: 0.2, alpha: 1.0)
				self.contentView.learnAnythingLabel.fadeIn(withDuration: 0.2, alpha: 1.0)
				self.contentView.facebookButton2.fadeIn(withDuration: 0.2, alpha: 1.0)
				self.contentView.infoLabel.fadeIn(withDuration: 0.2, alpha: 1.0)
			})
		} else if (touchStartView is RegistrationNextButton) {
			signIn()
		}
	}
	
	private func phoneRegex(_ phone: String) -> Bool {
		let phoneRegex = "^((\\+)|(00))[0-9]{6,14}$"
		let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
		return phoneTest.evaluate(with: phone)
	}
	
	private func signIn() {
		let phoneNumber = contentView.phoneTextField.textField.text!
		PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber.cleanPhoneNumber(), uiDelegate: nil) { (verificationId, error) in
			if let error = error {
				print("Error:", error.localizedDescription)
				//self.contentView.nextButton.isUserInteractionEnabled = true
			} else {
				
				UserDefaults.standard.set(verificationId, forKey: Constants.VRFCTN_ID)
				Registration.phone = phoneNumber.cleanPhoneNumber()
				self.navigationController?.pushViewController(Verification(), animated: true)
			}
		}
	}
	
	private func facebookSignIn () {
		fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
			if let error = error {
				print("Failed to login: \(error.localizedDescription)")
				return
			}
			guard let accessToken = FBSDKAccessToken.current() else {
				print("Failed to get access token")
				return
			}
			let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
			
			// Perform login by calling Firebase APIs
			Auth.auth().signIn(with: credential, completion: { (user, error) in
				if let error = error {
					print("Login error: \(error.localizedDescription)")
					return
				}else{
					let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":" id, name, email"])
					
					graphRequest.start(completionHandler: { (connection, result, error) -> Void in
						
						if let error = error {
							print(error.localizedDescription)
						}
						else
						{
							let data:[String:AnyObject] = result as! [String : AnyObject]
							print(data)
						}
					})
					print("Successful!")
					//manage users information
					//then determine where to go from here.
					//authfil user information?
				}
			})
		}
	}
}
extension SignIn : UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
		let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)
		
		let decimalString = components.joined(separator: "") as NSString
		let length = decimalString.length
		let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
		
		if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
			let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
			
			return (newLength > 10) ? false : true
		}
		var index = 0 as Int
		let formattedString = NSMutableString()
		
		if hasLeadingOne {
			formattedString.append("1 ")
			index += 1
		}
		if (length - index) > 3 {
			let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
			formattedString.appendFormat("(%@) ", areaCode)
			index += 3
		}
		if length - index > 3 {
			let prefix = decimalString.substring(with: NSMakeRange(index, 3))
			formattedString.appendFormat("%@-", prefix)
			index += 3
		}
		
		let remainder = decimalString.substring(from: index)
		formattedString.append(remainder)
		textField.text = formattedString as String
		return false
	}
}
