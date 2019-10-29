//
//  signIn.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/16/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import FacebookLogin
import FacebookCore
import Alamofire
import SwiftyJSON
import IQKeyboardManager

class PhoneTextFieldView: InteractableView, Interactable {
	
	let phoneNumberLabel: UILabel = {
		let label = UILabel()
		label.text = "Phone number"
		label.font = Fonts.createBoldSize(14)
		label.textColor = .white
		return label
	}()
	
	var textField: NoPasteTextField = {
		let textField = NoPasteTextField()
		textField.font = Fonts.createSize(16)
		textField.keyboardAppearance = .dark
		textField.textColor = .white
		textField.tintColor = .white
		return textField
	}()
	
	var flag: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "flag")
		imageView.scaleImage()
		return imageView
	}()
	
	var plusOneLabel: UILabel = {
		let label = UILabel()
		label.textColor = Colors.registrationGray
		label.font = Fonts.createSize(16)
		label.text = "+1"
		label.textAlignment = .center
		
		return label
	}()
    
	var line = UIView()
	
	let invalidNumberLabel: UILabel = {
		let label = UILabel()
		label.text = "Invalid phone number"
		label.font = Fonts.createBoldSize(14)
		label.textColor = .red
		label.isHidden = true
		return label
	}()
	
	override func configureView() {
		addSubview(phoneNumberLabel)
		addSubview(textField)
		addSubview(line)
		addSubview(flag)
		addSubview(plusOneLabel)
		addSubview(invalidNumberLabel)
		super.configureView()
		
		line.backgroundColor = Colors.registrationGray
		applyConstraints()
	}
	
	override func applyConstraints() {
		phoneNumberLabel.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.equalToSuperview()
			make.left.equalToSuperview()
		}

		flag.snp.makeConstraints { make in
			make.height.equalTo(45)
			make.width.equalTo(30)
			make.left.equalToSuperview()
			make.bottom.equalToSuperview().inset(35)
		}
		
		plusOneLabel.snp.makeConstraints { make in
			make.left.equalTo(flag.snp.right)
			make.bottom.equalToSuperview().inset(35)
			make.width.equalTo(45)
			make.height.equalTo(flag)
		}
		
		textField.snp.makeConstraints { make in
			make.left.equalTo(plusOneLabel.snp.right)
			make.right.equalToSuperview()
			make.bottom.equalToSuperview().inset(35)
			make.height.equalTo(45)
		}
		
		line.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview().inset(35)
			make.height.equalTo(1)
		}
		
		invalidNumberLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.bottom.equalToSuperview()
			make.right.equalToSuperview()
			make.height.equalTo(15)
		}
	}
	
	func showInvalidPhoneNumber() {
		invalidNumberLabel.isHidden = false
		line.backgroundColor = .red
	}
	
	func hideInvalidPhoneNumber() {
		invalidNumberLabel.isHidden = true
		line.backgroundColor = Colors.registrationGray
	}
}

class SignInVC: UIViewController {
	
	var verificationId: String!
	
	lazy var contentView: SignInVCView = {
		let view = SignInVCView()
		view.delegate = self
		return view
	}()
	
	let accessoryView: RegistrationAccessoryView = {
		let view = RegistrationAccessoryView()
		return view
	}()
	
	override var inputAccessoryView: UIView? {
		return RegistrationAccessoryView()
	}
	
	override func loadView() {
		view = contentView
	}
	
	var keyboardAnimationDuration: Double?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTargets()
		hideKeyboardWhenTappedAround()
		contentView.phoneTextField.textField.delegate = self
		accessoryView.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
		contentView.phoneTextField.textField.inputAccessoryView = accessoryView
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: false)
		hideTabBar(hidden: true)
				
		IQKeyboardManager.shared().isEnabled = true
	}
	
	@objc func keyboardWillShow(_ notification: Notification) {
		if let _: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
			guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
			keyboardAnimationDuration = duration
		}
	}
	
	func setupTargets() {
		contentView.facebookButton.addTarget(self, action: #selector(handleFacebookSignIn), for: .touchUpInside)
		accessoryView.nextButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
		let tap = UITapGestureRecognizer(target: self, action: #selector(textViewTapped(_:)))
		tap.numberOfTapsRequired = 1
		contentView.infoTextView.addGestureRecognizer(tap)
	}
	
	@objc func handleFacebookSignIn() {
		let loginManager = LoginManager()
		loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { (result) in
			switch result {
			case .failed(let error):
				print(error)
			case .cancelled:
				print("User cancelled login.")
			case .success:
				self.completeFacebookSignIn()
				print("Login result", result)
			}
		}
	}
	
	func completeFacebookSignIn() {
		displayLoadingOverlay()
		guard let accessToken = AccessToken.current?.tokenString else { return }
		let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
		Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
			guard error == nil else {
				self.dismissOverlay()
				self.showSignInError()
				return
			}
			guard let uid = authResult?.user.uid else {
				self.dismissOverlay()
				return
			}
			self.displayLoadingOverlay()
			Database.database().reference().child("student-info").child(uid).observeSingleEvent(of: .value) { (snapshot) in
				if snapshot.exists() {
					FirebaseData.manager.signInLearner(uid: uid, isFacebookLogin: true) { successful in
						if successful {
							Database.database().reference().child("account").child(uid).observeSingleEvent(of: .value) { snapshot in
								self.dismissOverlay()
								guard let dicAccount = snapshot.value as? [String: Any] else { return }
								
								if nil == dicAccount["facebook"] as? [String: Any] {
									self.getFacebookProfile() { userData in
										self.setupForRegistration(userData: userData)
										if let facebookInfo = Registration.facebookInfo {
											snapshot.ref.child("facebook").updateChildValues(facebookInfo)
										}
									}
								}
							}
							Registration.setLearnerDefaults()
							RootControllerManager.shared.setupLearnerTabBar(controller: LearnerMainPageVC())
						} else {
							self.dismissOverlay()
							self.navigationController?.pushViewController(SignInVC(), animated: true)
						}
					}
				} else {
					self.dismissOverlay()
					Registration.uid = uid
					self.getFacebookProfile() { userData in
						self.setupForRegistration(userData: userData)
					}
				}
			}
		}

	}
	
	func showSignInError() {
		let ac = UIAlertController(title: "Account already exists.", message: "Please sign in and link to Facebook in settings.", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
		self.present(ac, animated: true, completion: nil)
	}
	
	func setupForRegistration(userData: [String: Any]?) {
		guard let data = userData else { return }
		guard let email = data["email"] as? String else { return }
		
		var facebookInfo: [String: Any] = [:]
		
		Registration.email = email
		AccountService.shared.currentUserType = .lRegistration
		
		
		if let name = data["name"] as? String, !name.isEmpty {
			Registration.name = name
		} else if let firstName = data["firstname"] as? String,
			let lastName = data["lastname"] as? String,
			!firstName.isEmpty, !lastName.isEmpty {
			Registration.name = "\(firstName) \(lastName)"
		} else {
			Registration.name = ""
		}
		
		facebookInfo["email"] = email
		facebookInfo["name"] = Registration.name
		if let userId = data["id"] as? String {
			Registration.studentImageURL = "https://graph.facebook.com/\(userId)/picture?type=large"
			facebookInfo["id"] = userId
			facebookInfo["imageUrl"] = Registration.studentImageURL
			Registration.facebookInfo = facebookInfo
			let next = BirthdayVC()
			next.isFacebookManaged = true
			self.navigationController?.pushViewController(next, animated: true)
		}
	}

	func getFacebookProfile(completion: @escaping ([String: Any]?) -> ()) {
		let params = ["fields": "id, name, first_name, last_name, email", "redirect": "false"]
		let graphRequest = GraphRequest(graphPath: "me", parameters: params)
		graphRequest.start { _, response, error in
			if let error = error {
				print("error in graph request:", error)
				completion(nil)
			} else {
				if let responseDictionary = response as? [String: Any] {
					print("Facebook response dictionary", responseDictionary)
					completion(responseDictionary)
				}
			}
		}
	}
	
	@objc func signIn() {
		let phoneNumber = contentView.phoneTextField.textField.text!
		guard phoneNumber.cleanPhoneNumber().isPhoneNumber else {
			contentView.phoneTextField.showInvalidPhoneNumber()
			return
		}
		displayLoadingOverlay()
		PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber.cleanPhoneNumber(), uiDelegate: nil) { verificationId, error in
			if let error = error {
				AlertController.genericErrorAlert(self, title: "Error:", message: error.localizedDescription)
			} else {
				UserDefaults.standard.set(verificationId, forKey: Constants.VRFCTN_ID)
				Registration.phone = phoneNumber.cleanPhoneNumber()
				self.navigationController?.pushViewController(VerificationVC(), animated: true)
			}
		}
		dismissOverlay()
	}
	
	@objc func textViewTapped(_ recognizer: UITapGestureRecognizer) {
		guard let textView = recognizer.view as? UITextView else {
			return
		}
		var location: CGPoint = recognizer.location(in: textView)
		location.x -= textView.textContainerInset.left
		location.y -= textView.textContainerInset.top
		
		let charIndex = textView.layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
		
		guard charIndex < textView.textStorage.length else {
			return
		}
		
		var range = NSRange(location: 0, length: 0)
		
		if let id = textView.attributedText.attribute(NSAttributedString.Key.init(rawValue: "id"), at: charIndex, effectiveRange: &range) as? String {
			let vc = WebViewVC()
			
			switch id {
			case "terms-of-service":
				vc.navigationItem.title = "Terms of Service"
				vc.url = "https://www.quicktutor.com/legal/terms-of-service"
				vc.loadAgreementPdf()
				navigationController?.pushViewController(vc, animated: true)
			case "privacy-policy":
				vc.navigationItem.title = "Privacy Policy"
				vc.url = "https://quicktutor.com/legal/privacy-policy"
				vc.loadAgreementPdf()
				navigationController?.pushViewController(vc, animated: true)
			case "payment-terms-of-service":
				vc.navigationItem.title = "Payment Terms of Service"
				vc.url = "https://quicktutor.com/legal/tutor-payment-policy"
				vc.loadAgreementPdf()
				navigationController?.pushViewController(vc, animated: true)
			case "nondiscrimintation-policy":
				vc.navigationItem.title = "Non-Discrimination Policy"
				vc.url = "https://www.quicktutor.com/community/support"
				vc.loadAgreementPdf()
				navigationController?.pushViewController(vc, animated: true)
			default: break
			}
		}
	}
	
}
extension SignInVC: UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		contentView.phoneTextField.hideInvalidPhoneNumber()
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


extension String {
	var isPhoneNumber: Bool {
		do {
			let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
			let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
			if let res = matches.first {
				return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count && self.count == 12
			} else {
				return false
			}
		} catch {
			return false
		}
	}
}

extension SignInVC: SignInVCViewDelegate {
	func backButtonTapped() {
		navigationController?.popToRootViewController(animated: true)
	}
}
