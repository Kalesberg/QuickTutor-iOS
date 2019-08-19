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

class UserPolicyVC: BaseRegistrationController {
    
    let contentView: UserPolicyVCView = {
        let view = UserPolicyVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        removeNavBarBackButton()
        progressView.isHidden = true
    }
    
    func setupTargets() {
        contentView.learnMoreButton.addTarget(self, action: #selector(learnMoreButtonPressed(_:)), for: .touchUpInside)
        contentView.acceptButton.addTarget(self, action: #selector(accepted), for: .touchUpInside)
        contentView.declineButton.addTarget(self, action: #selector(declined), for: .touchUpInside)
    }
    
    func removeNavBarBackButton() {
        navigationItem.setHidesBackButton(true, animated:true);
    }
    
    func createCustomer(_ completion: @escaping (Error?, String?) -> Void) {
        guard let email = Registration.email else { return }
        
        let requestString = "\(Constants.API_BASE_URL)/stripes/customers"
        let params = [
            "email": email,
            "description": "Student Account"
        ]
        Alamofire.request(requestString, method: .post, parameters: params)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success(let value as [String: Any]):
                    if let customerId = value["id"] as? String {
                        completion(nil, customerId)
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(error, nil)
                default:
                    completion(nil, nil)
            }
        }
    }
    
    func checkEmailIsInUse(_ completion: @escaping (Error?, String?) -> Void) {
        Auth.auth().fetchProviders(forEmail: Registration.email!, completion: { response, error in
            if let error = error {
                completion(error, nil)
            } else {
                if response == nil {
                    // TODO: Should probably remove guard statement, just there so that it builds
                    guard let credential = Registration.emailCredential else { return }
                    Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { _, error in
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
    
    func submitBackgroundTasks(_ completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        
        displayLoadingOverlay()
        
        group.enter()
        createCustomer { error, cusId in
            if let error = error {
                completion(error)
            } else if let cusId = cusId {
                Registration.customerId = cusId
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
        
        if nil == Registration.studentImageURL
            || Registration.studentImageURL.isEmpty {
            group.enter()
            FirebaseData.manager.uploadImage(data: Registration.imageData, number: "1") { error, imageUrl in
                if let error = error {
                    completion(error)
                } else if let imageUrl = imageUrl {
                    Registration.studentImageURL = imageUrl
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(nil)
        }
    }
    
    func genericError(title: String = "Error", message: String?) {
        AlertController.genericErrorAlert(self, title: title, message: message)
    }
    
    @objc func accepted() {
        displayLoadingOverlay()
        
        submitBackgroundTasks {[weak self] error in
            if let error = error {
                self?.genericError(message: error.localizedDescription)
            } else {
                var account: [String: Any] = [
                     "phn": Registration.phone ?? "",
                     "age": Registration.age,
                     "em": Registration.email,
                     "bd": Registration.dob,
                     "logged": "",
                     "init": (Date().timeIntervalSince1970)
                ]
                if let facebookInfo = Registration.facebookInfo {
                    account["facebook"] = facebookInfo
                }
                
                let studentInfo: [String: Any] = [
                    "nm": Registration.name,
                    "r": 5.0,
                    "cus": Registration.customerId,
                    "img": [
                        "image1": Registration.studentImageURL
                    ]
                ]
                
                guard let registrationId = Registration.uid else {
                    self?.genericError(message: "Invalid registration id")
                    self?.dismissOverlay()
                    return
                }
                
                let newUser: [String: Any] = ["/account/\(registrationId)/": account, "/student-info/\(registrationId)/": studentInfo]
                
                Database.database().reference().root.updateChildValues(newUser) { error, _ in
                    if let error = error {
                        self?.genericError(message: error.localizedDescription)
                        self?.dismissOverlay()
                    } else {
                        Registration.setRegistrationDefaults()
                        AccountService.shared.currentUserType = .learner
                        
                        // create QL follwoers
                        let params = [
                            "accountId": registrationId
                        ]
                        Alamofire.request("\(Constants.API_BASE_URL)/quicklink/followers", method: .post, parameters: params, encoding: URLEncoding.default)
                            .validate()
                            .responseString(completionHandler: { response in
                                switch response.result {
                                case .success(var value):
                                    value = String(value.filter { !" \n\t\r".contains($0) })
                                    print(value)
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            })
                        self?.navigationController?.pushViewController(TheChoiceVC(), animated: true)
                    }
                }
            }
        }
    }
    
    @objc func declined() {
        let alertController = UIAlertController(title: "All your progress will be lost.", message: "By pressing delete your account will not be created.", preferredStyle: UIAlertController.Style.alert)
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
        next.navigationItem.title = "Non-Discrimination Policy"
        next.url = "https://www.quicktutor.com/community/support"
        next.loadAgreementPdf()
        navigationController?.pushViewController(next, animated: true)
    }
    
}
