//
//  CloseAccountSubmission.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import FirebaseAuth

class CloseAccountSubmissionView : MainLayoutTitleBackTwoButton, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	var submitButton = NavbarButtonSubmit()
	
	override var rightButton: NavbarButton {
		get {
			return submitButton
		} set {
			submitButton = newValue as! NavbarButtonSubmit
		}
	}
	
	let contentView = UIView()
	
	let reasonLabel : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createBoldSize(18)
		label.textColor = .white
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let reasonContainer : UIView = {
		let view = UIView()
		
		view.backgroundColor = Colors.qtRed
		view.layer.cornerRadius = 5
		
		return view
	}()
	
	let helpLabel : UILabel = {
		let label = UILabel()
		
		label.text = "Is there anything we can do to help your experience?"
		label.textColor = .white
		label.textAlignment = .left
		label.font = Fonts.createBoldSize(16)
		label.numberOfLines = 2
		
		return label
	}()
	
	let textView = SubmissionTextView()
	
	override func configureView() {
		addKeyboardView()
		addSubview(contentView)
		contentView.addSubview(reasonContainer)
		reasonContainer.addSubview(reasonLabel)
		contentView.addSubview(helpLabel)
		contentView.addSubview(textView)
		super.configureView()
		
		navbar.backgroundColor = Colors.qtRed
		statusbarView.backgroundColor = Colors.qtRed
		title.label.text = "Close Account"
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		contentView.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.9)
			make.top.equalTo(navbar.snp.bottom)
			make.bottom.equalTo(keyboardView.snp.top)
			make.centerX.equalToSuperview()
		}
		
		reasonContainer.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(15)
			make.width.equalTo(250)
			make.centerX.equalToSuperview()
			make.height.equalTo(55)
		}
		
		reasonLabel.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		helpLabel.snp.makeConstraints { (make) in
			make.top.equalTo(reasonContainer.snp.bottom).inset(-15)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
		
		textView.snp.makeConstraints { (make) in
			make.top.equalTo(helpLabel.snp.bottom).inset(-15)
			make.width.equalToSuperview()
			make.bottom.equalToSuperview().inset(40)
			make.centerX.equalToSuperview()
		}
	}
}


class SubmissionTextView : EditBioTextView {
	
	override func configureView() {
		addSubview(textView)
		
		backgroundColor = Colors.registrationDark
		layer.borderWidth = 1.0
		layer.borderColor = UIColor.black.cgColor
		layer.cornerRadius = 10
		
		applyConstraints()
	}
}


class CloseAccountSubmission : BaseViewController {

	override var contentView: CloseAccountSubmissionView {
		return view as! CloseAccountSubmissionView
	}
	
	var reason : String!
	private var verificationId : String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.hideKeyboardWhenTappedAround()
	}
	
	override func loadView() {
		view = CloseAccountSubmissionView()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	private func getTutorAccount(_ completion: @escaping ([String]) -> Void) {
		FirebaseData.manager.getTutor(AccountService.shared.currentUser.uid, isQuery: false) { (tutor) in
			if let tutor = tutor {
				CurrentUser.shared.tutor = tutor
				var subcategories = [String]()
				for (_, value) in tutor.selected.enumerated() {
					subcategories.append(value.path)
				}
				completion(subcategories.unique)
			} else {
				completion([])
			}
		}
	}
	private func removeTutorAccount() {
		displayLoadingOverlay()
		getTutorAccount { (subcategories) in
			FirebaseData.manager.removeTutorAccount(uid: AccountService.shared.currentUser.uid, reason: self.reason, subcategory: subcategories, message: self.contentView.textView.textView.text, { (error) in
				if let error = error {
					self.dismissOverlay()
					AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
				} else {
					self.dismissOverlay()
					CurrentUser.shared.learner.isTutor = false
					self.navigationController?.pushViewController(LearnerPageViewController(), animated: true)
				}
			})
		}
	}
	private func removeBothAccounts() {
		guard let currentUser = Auth.auth().currentUser else { return }
		self.getTutorAccount({ (subcategories) in
			FirebaseData.manager.removeBothAccounts(uid: currentUser.uid, reason: self.reason, subcategory: subcategories, message: self.contentView.textView.textView.text!, { (error) in
				if let error = error {
					AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
				} else {
					currentUser.delete { (error) in
						if let error = error {
							let errorCode = AuthErrorCode(rawValue: error._code)
							if errorCode == AuthErrorCode.requiresRecentLogin {
								self.getUserCredentialsAlert()
							}
						} else {
							try! Auth.auth().signOut()
							print("Heu")
							self.navigationController?.pushViewController(SignIn(), animated: false)
						}
					}
				}
			})
		})
	}
	
	private func stripeish(deleteAccountType: Bool, completion: @escaping (Error?) -> Void) {
		
		//also need to remove Connect Account, need to check for balance, if 0 then delete, else payout, if unable to payout warn them, then they will need to give us a valid bank account, then retry. otherwise we take their cash.
		//				Stripe.removeCustomer(customerId: CurrentUser.shared.learner.customer) { (error) in
		//					if let error = error {
		//						print(error.localizedDescription)
		//					}
		//				}
		//				Stripe.removeConnectAccount(accountId: CurrentUser.shared.tutor.acctId, completion: { (error) in
		//					if let error = error {
		//						print(error.localizedDescription)
		//					}
		//				})
	}
	
	private func removeLearner() {
		guard let currentUser = Auth.auth().currentUser else { return }
		
		FirebaseData.manager.removeLearnerAccount(uid: currentUser.uid, reason: self.reason, { (error) in
			if let error = error {
				AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
			} else {
				currentUser.delete { (error) in
					if let error = error {
						let errorCode = AuthErrorCode(rawValue: error._code)
						if errorCode == AuthErrorCode.requiresRecentLogin {
							self.getUserCredentialsAlert()
						}
					} else {
						try! Auth.auth().signOut()
						print("hi.")
						self.navigationController?.pushViewController(SignIn(), animated: false)
					}
				}
			}
		})
	}
	private func reauthenticateUser(code: String, completion: @escaping (Error?) -> Void) {
		guard let id = self.verificationId else { return }
		let credential : PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: id, verificationCode: code)
		let currentUser = Auth.auth().currentUser
		currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { (_, error) in
			if let error = error {
				completion(error)
			} else {
				completion(nil)
			}
		})
	}
	private func getUserCredentialsAlert() {
		let phoneNumber = CurrentUser.shared.learner.phone.cleanPhoneNumber()
		PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationId, error) in
			if let error = error {
				AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
			} else if let id = verificationId {
				self.verificationId = id
				self.displayPhoneVerificationAlert(message: "Please enter the verifcation code sent to: \(CurrentUser.shared.learner.phone.formatPhoneNumber())")
			} else {
				AlertController.genericErrorAlert(self, title: "Error", message: "Something went wrong, please try again.")
			}
		}
	}
	
	override func handleNavigation() {
		if(touchStartView is NavbarButtonSubmit) {
			getUserCredentialsAlert()
		} else if touchStartView is PhoneAuthenicationActionCancel {
			self.dismissPhoneAuthenticationAlert()
		} else if touchStartView is PhoneAuthenicationAction {
			if let view = self.view.viewWithTag(321) as? PhoneAuthenticationAlertView {
				guard let verificationCode = view.verificationTextField.text, !verificationCode.contains("—") else { return }
				view.verifyAction.isUserInteractionEnabled = false
				
				reauthenticateUser(code: verificationCode) { (error) in
					if let error = error {
						view.errorLabel.isHidden = false
						view.errorLabel.text = error.localizedDescription
						view.verifyAction.isUserInteractionEnabled = true
					} else {
						view.errorLabel.isHidden = true
						if CurrentUser.shared.learner.isTutor == false {
							self.removeLearner()
						} else {
							if DeleteAccount.type {
								self.removeTutorAccount()
							} else {
								self.removeBothAccounts()
							}
						}
						view.verifyAction.isUserInteractionEnabled = true
						self.dismissPhoneAuthenticationAlert()
					}
				}
			}
		}
	}
}

