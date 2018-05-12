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
		FirebaseData.manager.getTutor(CurrentUser.shared.learner.uid) { (tutor) in
			if let tutor = tutor {
				CurrentUser.shared.tutor = tutor
				
				var subcategories = [String]()
				
				for (_, value) in tutor.selected.enumerated() {
					subcategories.append(value.path)
				}
				completion(subcategories.unique)
			}
		}
	}
	private func deleteUser() {
		let password : String? = KeychainWrapper.standard.string(forKey: "emailAccountPassword")
		Auth.auth().signIn(withEmail: CurrentUser.shared.learner.email!, password: password!) { (user, error) in
			if let error = error {
				print(error.localizedDescription)
			} else if let user = user {
				user.delete(completion: { (error) in
					if let error = error {
						print(error.localizedDescription)
					}
					print("here.")
					self.navigationController?.pushViewController(SignIn(), animated: false)
				})
			}
		}
	}
	
	private func removeAccount() {
		
		switch AccountService.shared.currentUserType {
		case .learner:
			if CurrentUser.shared.learner.isTutor {
				
				getTutorAccount { (subcategories) in
					FirebaseData.manager.removeBothAccounts(uid: CurrentUser.shared.learner.uid, reason: self.reason, subcategory: subcategories, message: self.contentView.textView.textView.text, { (error) in
						if let error = error {
							print(error.localizedDescription)
						} else {
							self.deleteUser()

						}
					})
					//also need to remove Connect Account, need to check for balance, if 0 then delete, else payout, if unable to payout warn them, then they will need to give us a valid bank account, then retry. otherwise we take their cash.
					Stripe.removeCustomer(customerId: CurrentUser.shared.learner.customer) { (error) in
						if let error = error {
							print(error.localizedDescription)
						}
					}
					Stripe.removeConnectAccount(accountId: CurrentUser.shared.tutor.acctId, completion: { (error) in
						if let error = error {
							print(error.localizedDescription)
						}
					})
				}
			} else {
				FirebaseData.manager.removeLearnerAccount(uid: CurrentUser.shared.learner.uid, reason: reason, message: contentView.textView.textView.text) { (error) in
					if let error = error{
						print(error.localizedDescription)
					}
					self.deleteUser()
				}
				
				Stripe.removeCustomer(customerId: CurrentUser.shared.learner.customer) { (error) in
					if let error = error {
						print(error.localizedDescription)
					}
				}
			}
			
		case .tutor:
			if let currentUser = CurrentUser.shared.tutor {
				//on tutor side, trying to delete account
				getTutorAccount { (subcategories) in
					FirebaseData.manager.removeTutorAccount(uid: currentUser.uid, reason: self.reason, subcategory: subcategories, message: self.contentView.textView.textView.text, { (error) in
						if let error = error{
							print(error.localizedDescription)
						} else {
							self.deleteUser()
						}
					})
				}
				Stripe.removeConnectAccount(accountId: CurrentUser.shared.tutor.acctId, completion: { (error) in
					if let error = error {
						print(error.localizedDescription)
					}
				})
				//need to send email after this and somehow delete their authentication.
			}
		}
	}
	override func handleNavigation() {
		if(touchStartView is NavbarButtonSubmit) {
			removeAccount()
		}
	}
}
