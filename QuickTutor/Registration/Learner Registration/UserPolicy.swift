//
//  UserPolicy.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//


import UIKit
import Firebase
import Stripe
import Alamofire

class UserPolicyView : RegistrationGradientView {
	
	var titleLabel      = RegistrationTitleLabel()
	var textLabel       = LeftTextLabel()
	var buttonView      = UIView()
	var learnMoreButton = LearnMoreButton()
	var acceptButton    = RegistrationBigButton()
	var declineButton   = RegistrationBigButton()
	
	override func configureView() {
		super.configureView()
		
		addSubview(titleLabel)
		addSubview(textLabel)
		addSubview(buttonView)
		addSubview(learnMoreButton)
		
		buttonView.addSubview(acceptButton)
		buttonView.addSubview(declineButton)
		
		titleLabel.label.text = "Before you join"
		
		textLabel.label.font = Fonts.createLightSize(17)
		textLabel.label.numberOfLines = 0
		textLabel.label.textColor = .white
		textLabel.label.text = "Whether it's your first time on QuickTutor or you've been with us from the very beginning, please commit to respecting and loving everyone in the QuickTutor community.\n\nI agree to treat everyone on QuickTutor regardless of their race, physical features, national origin, ethnicity, religion, sex, disability, gender identity, sexual orientation or age with respect and love, without judgement or bias."
		textLabel.label.adjustsFontSizeToFitWidth = true
		
		acceptButton.label.label.text = "Accept"
		
		declineButton.label.label.text = "Decline"
		
		textLabel.sizeToFit()
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		titleLabel.snp.makeConstraints { (make) in
			if #available(iOS 11.0, *) {
				make.top.equalTo(safeAreaLayoutGuide.snp.top)
			} else {
				make.top.equalTo(titleLabel.snp.top).inset(DeviceInfo.statusbarHeight)
			}
			make.bottom.equalTo(textLabel.snp.top)
			make.width.equalToSuperview().multipliedBy(0.8)
			make.centerX.equalToSuperview()
		}
		
		titleLabel.label.snp.remakeConstraints { (make) in
			make.centerY.equalToSuperview().multipliedBy(1.5)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
		
		textLabel.snp.makeConstraints { (make) in
			make.bottom.equalTo(learnMoreButton.snp.top)
			make.height.equalTo(320)
			make.left.equalTo(titleLabel)
			make.right.equalTo(titleLabel)
		}
		
		learnMoreButton.snp.makeConstraints { (make) in
			make.bottom.equalTo(buttonView.snp.top)
			make.top.equalTo(textLabel.snp.bottom)
			make.width.equalToSuperview().multipliedBy(0.8)
			make.centerX.equalToSuperview()
		}
		
		buttonView.snp.makeConstraints { (make) in
			make.height.equalToSuperview().multipliedBy(0.3)
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide)
			} else {
				make.bottom.equalToSuperview()
			}
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
		
		acceptButton.snp.makeConstraints { (make) in
			make.height.equalTo(55)
			make.width.equalTo(270)
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(0.6)
		}
		
		declineButton.snp.makeConstraints { (make) in
			make.height.equalTo(55)
			make.width.equalTo(270)
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(1.4)
		}
	}
}


class LearnMoreButton : InteractableView, Interactable {
	
	var label = UILabel()
	
	override func configureView() {
		addSubview(label)
		super.configureView()
		
		label.font = Fonts.createSize(20)
		label.text = "Learn More »"
		label.textColor = .white
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
	
	func touchStart() {
		label.alpha = 0.7
	}
	
	func didDragOff() {
		label.alpha = 1.0
	}
}


class UserPolicy : BaseViewController {
	
	override var contentView: UserPolicyView {
		return view as! UserPolicyView
	}
	
	override func loadView() {
		view = UserPolicyView()
	}
	
	private let ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.acceptButton.isUserInteractionEnabled = true
	}
	
	func createCustomer(_ completion: @escaping (Error?, String?) -> Void) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/createcustomer.php"
		let params : [String : Any] = ["email" : Registration.email, "description" : "Student Account"]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
					
				case .success(var value):
					value = String(value.filter{ !" \n\t\r".contains($0)})
					
					completion(nil, value)
				case .failure(let error):
					completion(error, nil)
				}
			})
	}
	private func checkEmailIsInUse(_ completion: @escaping (Error?, String?) -> Void) {
		Auth.auth().fetchProviders(forEmail: Registration.email!, completion: { (response, error) in
			if let error = error {
				completion(error, nil)
			} else {
				if response == nil {
					Auth.auth().currentUser?.linkAndRetrieveData(with: Registration.emailCredential, completion: { (_, error) in
						if let error = error {
							completion(error, nil)
						} else {
							completion(nil, nil)
						}
					})
				} else {
					completion(nil, "Email already in use.")
				}
			}
		})
	}
	
	private func submitBackgroundTasks(_ completion: @escaping (Error?) ->()) {
		let group = DispatchGroup()
		
		self.displayLoadingOverlay()
		
		group.enter()
		createCustomer { (error, cusId) in
			if let error = error {
				print("error1")
				completion(error)
			} else if let cusId = cusId {
				Registration.customerId = cusId
				print("customerId created.")
			}
			group.leave()
		}
		
		group.enter()
		checkEmailIsInUse { (error, message) in
			if let error = error {
				print("error2")
				completion(error)
			} else if message != message {
				let error = NSError(domain: "", code: 12, userInfo: nil)
				completion(error)
			} else {
				print("email is good")
			}
			group.leave()
		}
		
		group.enter()
		FirebaseData.manager.uploadImage(data: Registration.imageData, number: "1") { (error, imageUrl) in
			if let error = error {
				print("error3")
				completion(error)
			} else if let imageUrl = imageUrl {
				Registration.studentImageURL = imageUrl
				print("image uploaded.")

			}
			group.leave()
		}
		
		group.notify(queue: .main) {
			print("completed.")
			completion(nil)
		}
	}
	private func accepted() {
		self.displayLoadingOverlay()
		
		submitBackgroundTasks { (error) in
			if let error = error {
				AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
			} else {
				let account : [String : Any] =
					["phn" : Registration.phone,"age" : Registration.age, "em" : Registration.email, "bd" : Registration.dob, "logged" : "", "init" : (Date().timeIntervalSince1970 * 1000)]
				
				let studentInfo : [String : Any] =
					["nm" : Registration.name, "r" : 5.0, "cus" : Registration.customerId,
					 "img": ["image1" : Registration.studentImageURL, "image2" : "", "image3" : "", "image4" : ""]
				]
				
				let newUser : [String : Any] = ["/account/\(Registration.uid!)/" : account, "/student-info/\(Registration.uid!)/" : studentInfo]
				
				self.ref.root.updateChildValues(newUser) { (error, reference) in
					if let error = error {
						AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
						self.dismissOverlay()
					} else {
						Registration.setRegistrationDefaults()
						AccountService.shared.currentUserType = .learner
						self.navigationController?.pushViewController(TheChoice(), animated: true)
					}
				}
			}
		}
	}
	
	private func declined() {
		self.displayLoadingOverlay()
		let alertController = UIAlertController(title: "All your progress will be deleted", message: "By pressing delete your account will not be created.", preferredStyle: UIAlertControllerStyle.alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
			self.dismiss(animated: true, completion: nil)
			self.dismissOverlay()
		}
		
		let delete = UIAlertAction(title: "Delete", style: .destructive) { (delete) in
			FirebaseData.manager.removeLearnerAccount(uid: Registration.uid!, reason: "declined policy", { (error) in
				if let error = error{
					AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
					self.dismissOverlay()
				} else {
					self.dismissOverlay()
					self.navigationController?.popToRootViewController(animated: true)
				}
			})
		}
		alertController.addAction(cancel)
		alertController.addAction(delete)
		self.present(alertController, animated: true, completion: nil)
	}
	override func handleNavigation() {
		if(touchStartView == contentView.acceptButton) {
			accepted()
			contentView.acceptButton.isUserInteractionEnabled = false
		} else if (touchStartView == contentView.declineButton) {
			declined()
			print("decline")
		} else if (touchStartView == contentView.learnMoreButton) {
			guard let url = URL(string: "https://www.quicktutor.com") else {
				return
			}
			if #available(iOS 10, *) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			} else {
				UIApplication.shared.openURL(url)
			}
		}
	}
}

