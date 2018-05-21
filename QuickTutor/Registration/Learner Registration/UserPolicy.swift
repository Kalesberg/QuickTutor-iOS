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
			make.top.equalTo(safeAreaLayoutGuide.snp.top)
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
			make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
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
	func createCustomer(_ completion: @escaping (String?) -> Void) {		
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/createcustomer.php"
		let params : [String : Any] = ["email" : Registration.email, "description" : "Student Account"]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				
				case .success(var value):
					value = String(value.filter{ !" \n\t\r".contains($0)})
					completion(value)
				case .failure:
					completion(nil)
				}
			})
	}
	
	private func accepted() {
		var studentInfo : [String : Any]!
		self.displayLoadingOverlay()
		createCustomer { (cusID) in
			if let cusID = cusID {
				studentInfo =
					["nm" : Registration.name, "r" : 5.0, "cus" : cusID,
					 "img": ["image1" : Registration.studentImageURL, "image2" : "", "image3" : "", "image4" : ""]
					]
			}
			
			let account : [String : Any] =
				["phn" : Registration.phone,"age" : Registration.age, "em" : Registration.email, "bd" : Registration.dob, "logged" : "", "init" : (Date().timeIntervalSince1970 * 1000)]
			
			let newUser : [String : Any] = ["/account/\(Registration.uid!)/" : account, "/student-info/\(Registration.uid!)/" : studentInfo]
			
			self.ref.root.updateChildValues(newUser) { (error, reference) in
				if let error = error {
					print(error.localizedDescription)
					self.dismissOverlay()
				} else {
					Auth.auth().fetchProviders(forEmail: Registration.email!, completion: { (response, error) in
						if let error = error {
							print(error)
							self.dismissOverlay()
						} else {
							if response == nil {
								Auth.auth().currentUser?.link(with: Registration.emailCredential, completion: { (user, _) in
									if let error = error {
										print(error.localizedDescription)
										self.dismissOverlay()
									} else {
										self.dismissOverlay()
										Registration.setRegistrationDefaults()
										AccountService.shared.currentUserType = .learner
										self.navigationController?.pushViewController(TheChoice(), animated: true)
									}
								})
							} else {
								self.dismissOverlay()
								print("email already in use.")
							}
						}
					})
					
				}
			}
		}
	}
	
	private func declined() {
		self.displayLoadingOverlay()
		let alertController = UIAlertController(title: "All your progress will be deleted", message: "By pressing delete your account will not be created.", preferredStyle: UIAlertControllerStyle.alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
			self.dismiss(animated: true, completion: nil)
		}
		
		let delete = UIAlertAction(title: "Delete", style: .destructive) { (delete) in
			FirebaseData.manager.removeLearnerAccount(uid: Registration.uid!, reason: "declined policy", { (error) in
				if let error = error{
					print(error)
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
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

