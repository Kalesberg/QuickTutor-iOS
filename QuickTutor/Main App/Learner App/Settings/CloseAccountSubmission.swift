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
	var userId : String = (AccountService.shared.currentUserType == .learner) ? CurrentUser.shared.learner.uid : CurrentUser.shared.tutor.uid
	var userType : UserType = (AccountService.shared.currentUserType == .learner) ? .learner : .tutor
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func loadView() {
		view = CloseAccountSubmissionView()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	private func getTutorAccount(_ completion: @escaping ([String]) -> Void) {
		FirebaseData.manager.getTutor(userId, isQuery: false) { (tutor) in
			if let tutor = tutor {
				CurrentUser.shared.tutor = tutor
				
				var subcategories = [String]()
				
				for (_, value) in tutor.selected.enumerated() {
					subcategories.append(value.path)
				}
				completion(subcategories.unique)
			}
			completion([])
		}
	}
	
	private func removeAccount(authResult: AuthDataResult, deleteAccountType: Bool, completion: @escaping (Error?) -> Void) {
		
		switch deleteAccountType {
			
		case true:
			self.displayLoadingOverlay()
			getTutorAccount { (subcategories) in
				FirebaseData.manager.removeTutorAccount(uid: authResult.user.uid, reason: self.reason, subcategory: subcategories, message: self.contentView.textView.textView.text, { (error) in
					if let error = error {
						completion(error)
					}
					self.dismissOverlay()
					CurrentUser.shared.learner.isTutor = false
					UserDefaults.standard.set(true, forKey: "showHomePage")
					self.navigationController?.pushViewController(LearnerPageViewController(), animated: false)
					completion(nil)
				})
			}
			//			Stripe.removeConnectAccount(accountId: CurrentUser.shared.tutor.acctId, completion: { (error) in
			//				if let error = error {
			//					print(error.localizedDescription)
			//				}
		//			})
		case false:
			self.displayLoadingOverlay()
			authResult.user.delete { (error) in
				if let error = error {
					completion(error)
				} else {
					self.getTutorAccount { (subcategories) in
						FirebaseData.manager.removeBothAccounts(uid: authResult.user.uid, reason: self.reason, subcategory: subcategories, message: self.contentView.textView.textView.text, { (error) in
							if let error = error {
								completion(error)
							}
						})
					}
				}
				self.dismissOverlay()
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
		}
	}

	private func getUserCredentialsAlert(_ completion: @escaping (AuthDataResult?) -> Void) {
		let alertController = UIAlertController(title: "Highly Sensitive Operation", message: "In order to remove your account we will need to verify your account.", preferredStyle: .alert)
		alertController.addTextField { (textField) in
			textField.placeholder = "Email"
			textField.keyboardType = .emailAddress
		}
		
		alertController.addTextField { (textField) in
			textField.placeholder = "Password"
			textField.isSecureTextEntry = true
		}
		
		let credentialAction = UIAlertAction(title: "Verify", style: .default) { (_) in
			let user = Auth.auth().currentUser
			let emailTextField = alertController.textFields![0]
			let passwordTextField = alertController.textFields![1]
			
			let credential : AuthCredential = EmailAuthProvider.credential(withEmail: emailTextField.text!, password: passwordTextField.text!)
			
			user?.reauthenticateAndRetrieveData(with: credential, completion: { (authResult, error) in
				if error != nil {
					completion(nil)
				} else if let result = authResult {
					completion(result)
				} else {
					 completion(nil)
					self.dismiss(animated: true, completion: nil)
				}
			})
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alertController.addAction(credentialAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	override func handleNavigation() {
		if(touchStartView is NavbarButtonSubmit) {
			print("ere")
			if (CurrentUser.shared.learner.isTutor == false) {
				
				getUserCredentialsAlert { (result) in
					if let result = result {
						result.user.delete(completion: { (error) in
							if let error = error {
								AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
							} else {
								self.displayLoadingOverlay()
								FirebaseData.manager.removeLearnerAccount(uid: result.user.uid, reason: self.reason, { (error) in
									if let error = error {
										AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
									} else {
										try! Auth.auth().signOut()
										self.navigationController?.pushViewController(SignIn(), animated: false)
									}
									self.dismissOverlay()
								})
							}
						})
					}
				}
			}
		} else {
			getUserCredentialsAlert { (result) in
				if let result = result {
					self.removeAccount(authResult: result, deleteAccountType: DeleteAccount.type) { (error) in
						if let error = error {
							AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
						}
					}
				}
			}
		}
	}
}
