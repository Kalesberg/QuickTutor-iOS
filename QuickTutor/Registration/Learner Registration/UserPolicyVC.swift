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

class UserPolicyView: BaseLayoutView {
    
	let titleLabel : RegistrationTitleLabel = {
		let label = RegistrationTitleLabel()
		label.label.text = "Before you join"
		return label
	}()
	
	let textLabel : LeftTextLabel = {
		let textLabel = LeftTextLabel()
		textLabel.label.font = Fonts.createLightSize(17)
		textLabel.label.numberOfLines = 0
		textLabel.label.textColor = .white
		textLabel.label.text = "Whether it's your first time on QuickTutor or you've been with us from the very beginning, please commit to respecting and loving everyone in the QuickTutor community.\n\nI agree to treat everyone on QuickTutor regardless of their race, physical features, national origin, ethnicity, religion, sex, disability, gender identity, sexual orientation or age with respect and love, without judgement or bias."
		textLabel.label.adjustsFontSizeToFitWidth = true
		textLabel.sizeToFit()
		return textLabel
	}()
	
    let buttonView = UIView()
	
	let learnMoreButton : UIButton = {
		let button = UIButton()
		button.titleLabel?.font = Fonts.createSize(20)
		button.setTitle("Learn More »", for: .normal)
		button.titleLabel?.textColor = .white
		return button
	}()
	
	let acceptButton : RegistrationBigButton = {
		let registrationBigButton = RegistrationBigButton()
		registrationBigButton.label.label.text = "Accept"
		return registrationBigButton
	}()
	
	let declineButton : RegistrationBigButton = {
		let registrationBigButton = RegistrationBigButton()
		registrationBigButton.label.label.text = "Decline"
		return registrationBigButton
	}()
    
    override func configureView() {
        super.configureView()
        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(buttonView)
        addSubview(learnMoreButton)
        buttonView.addSubview(acceptButton)
        buttonView.addSubview(declineButton)
		
		applyGradient(firstColor: (Colors.oldTutorBlue.cgColor), secondColor: (Colors.oldLearnerPurple.cgColor), angle: 160, frame: frame)

        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        titleLabel.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(titleLabel.snp.top).inset(DeviceInfo.statusbarHeight)
            }
            make.bottom.equalTo(textLabel.snp.top)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }
        titleLabel.label.snp.remakeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        textLabel.snp.makeConstraints { make in
            make.bottom.equalTo(learnMoreButton.snp.top)
            make.height.equalTo(320)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
        }
        learnMoreButton.snp.makeConstraints { make in
            make.bottom.equalTo(buttonView.snp.top)
            make.top.equalTo(textLabel.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }
        buttonView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.3)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        acceptButton.snp.makeConstraints { make in
            make.height.equalTo(55)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        declineButton.snp.makeConstraints { make in
            make.height.equalTo(55)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.4)
        }
    }
}

class UserPolicyVC: BaseViewController {
    
    override var contentView: UserPolicyView {
        return view as! UserPolicyView
    }
    
    override func loadView() {
        view = UserPolicyView()
    }
    
    private let ref: DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
    
    override func viewDidLoad() {
        super.viewDidLoad()
		contentView.learnMoreButton.addTarget(self, action: #selector(learnMoreButtonPressed(_:)), for: .touchUpInside)
    }
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.acceptButton.isUserInteractionEnabled = true
    }
    
    func createCustomer(_ completion: @escaping (Error?, String?) -> Void) {
        let requestString = "https://aqueous-taiga-32557.herokuapp.com/createcustomer.php"
        let params: [String: Any] = ["email": Registration.email, "description": "Student Account"]
        
        Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
            .validate(statusCode: 200..<300)
            .responseString(completionHandler: { response in
                switch response.result {
                    
                case .success(var value):
                    value = String(value.filter { !" \n\t\r".contains($0) })
                    
                    completion(nil, value)
                case .failure(let error):
                    completion(error, nil)
                }
            })
    }
    private func checkEmailIsInUse(_ completion: @escaping (Error?, String?) -> Void) {
        Auth.auth().fetchProviders(forEmail: Registration.email!, completion: { response, error in
            if let error = error {
                completion(error, nil)
            } else {
                if response == nil {
                    Auth.auth().currentUser?.linkAndRetrieveData(with: Registration.emailCredential, completion: { _, error in
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
    
    private func submitBackgroundTasks(_ completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        
        displayLoadingOverlay()
        
        group.enter()
        createCustomer { error, cusId in
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
        checkEmailIsInUse { error, message in
            if let error = error {
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
        FirebaseData.manager.uploadImage(data: Registration.imageData, number: "1") { error, imageUrl in
            if let error = error {
                completion(error)
            } else if let imageUrl = imageUrl {
                Registration.studentImageURL = imageUrl
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(nil)
        }
    }
    private func accepted() {
        displayLoadingOverlay()
        
        submitBackgroundTasks { error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else {
                let account: [String: Any] =
                    ["phn": Registration.phone, "age": Registration.age, "em": Registration.email, "bd": Registration.dob, "logged": "", "init": (Date().timeIntervalSince1970)]
                
                let studentInfo: [String: Any] =
                    ["nm": Registration.name, "r": 5.0, "cus": Registration.customerId,
                     "img": ["image1": Registration.studentImageURL, "image2": "", "image3": "", "image4": ""]]
                
                let newUser: [String: Any] = ["/account/\(Registration.uid!)/": account, "/student-info/\(Registration.uid!)/": studentInfo]
                
                self.ref.root.updateChildValues(newUser) { error, _ in
                    if let error = error {
                        AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                        self.dismissOverlay()
                    } else {
                        Registration.setRegistrationDefaults()
                        AccountService.shared.currentUserType = .learner
                        self.navigationController?.pushViewController(TheChoiceVC(), animated: true)
                    }
                }
            }
        }
    }
    private func declined() {
        let alertController = UIAlertController(title: "All your progress will be deleted", message: "By pressing delete your account will not be created.", preferredStyle: UIAlertController.Style.alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.displayLoadingOverlay()
            self.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(cancel)
        alertController.addAction(delete)
        present(alertController, animated: true, completion: nil)
    }
	
	@objc func learnMoreButtonPressed(_ sender: UIButton) {
		let next = WebViewVC()
		next.contentView.title.label.text = "Non-Discrimination Policy"
		next.url = "https://www.quicktutor.com/community/support"
		next.loadAgreementPdf()
		navigationController?.pushViewController(next, animated: true)
	}
    override func handleNavigation() {
        if touchStartView == contentView.acceptButton {
            accepted()
            contentView.acceptButton.isUserInteractionEnabled = false
        } else if touchStartView == contentView.declineButton {
            declined()
        }
    }
}
