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
        removeNavBarButton()
        progressView.isHidden = true
    }
    
    func setupTargets() {
        contentView.learnMoreButton.addTarget(self, action: #selector(learnMoreButtonPressed(_:)), for: .touchUpInside)
        contentView.acceptButton.addTarget(self, action: #selector(accepted), for: .touchUpInside)
        contentView.declineButton.addTarget(self, action: #selector(declined), for: .touchUpInside)
    }
    
    func removeNavBarButton() {
        navigationItem.leftBarButtonItem = nil
    }
    
    func createCustomer(_ completion: @escaping (Error?, String?) -> Void) {
        let requestString = "https://aqueous-taiga-32557.herokuapp.com/createcustomer.php"
        let params: [String: Any] = ["email": Registration.email ?? "unknown", "description": "Student Account"]
        
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
    
    @objc func accepted() {
        displayLoadingOverlay()
        
        submitBackgroundTasks { error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else {
                let account: [String: Any] =
                    ["phn": Registration.phone!, "age": Registration.age, "em": Registration.email, "bd": Registration.dob, "logged": "", "init": (Date().timeIntervalSince1970)]
                
                let studentInfo: [String: Any] =
                    ["nm": Registration.name, "r": 5.0, "cus": Registration.customerId,
                     "img": ["image1": Registration.studentImageURL, "image2": "", "image3": "", "image4": ""]]
                
                let newUser: [String: Any] = ["/account/\(Registration.uid!)/": account, "/student-info/\(Registration.uid!)/": studentInfo]
                
                Database.database().reference().root.updateChildValues(newUser) { error, _ in
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
    
    @objc func declined() {
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
        next.navigationItem.title = "Non-Discrimination Policy"
        next.url = "https://www.quicktutor.com/community/support"
        next.loadAgreementPdf()
        navigationController?.pushViewController(next, animated: true)
    }
    
}
