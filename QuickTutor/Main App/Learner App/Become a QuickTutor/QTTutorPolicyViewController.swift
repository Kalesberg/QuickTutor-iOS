//
//  QTTutorPolicyViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 5/28/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseAuth
import Stripe

class QTTutorPolicyViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tutorAgreementView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    
    static var controller: QTTutorPolicyViewController {
        return QTTutorPolicyViewController(nibName: String(describing: QTTutorPolicyViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: -10), radius: 10)
        
        tutorAgreementView.setupTargets { (state) in
            if state == .ended {
                let vc = WebViewVC()
                vc.navigationItem.title = "Independent Tutor Agreement"
                vc.url = "https://www.quicktutor.com/legal/ita"
                vc.loadAgreementPdf()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    // MARK: - Actions
    @IBAction func onCheckButtonClicked(_ sender: Any) {
        checkButton.isSelected = true
        displayLoadingOverlay()
        createConnectAccount { success in
            if success {
                self.switchToTutorSide({ success in
                    if success {
                        CurrentUser.shared.learner.isTutor = true
                        AccountService.shared.currentUserType = .tutor
                        RootControllerManager.shared.setupTutorTabBar(controller: QTTutorDashboardViewController.controller)
                    } else {
                        AlertController.genericErrorAlert(self, title: "Unable to Create Account", message: "Please verify your information was correct.")
                    }
                    self.dismissOverlay()
                })
            } else {
                AlertController.genericErrorAlert(self, title: "Unable to Create Account", message: "Please verify your information was correct.")
                self.dismissOverlay()
            }
        }
    }
    
    
    // MARK: - Functions
    func createConnectAccount(_ completion: @escaping (Bool) -> Void) {
        StripeService.createConnectAccountToken(ssn: TutorRegistration.ssn!, line1: TutorRegistration.line1, city: TutorRegistration.city, state: TutorRegistration.state, zipcode: TutorRegistration.zipcode) { token, error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else if let token = token {
                StripeService.createConnectAccount(bankAccountToken: TutorRegistration.bankToken!, connectAccountToken: token, { error, value in
                    if let error = error {
                        AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                        return completion(false)
                    }
                    guard let value = value, value.prefix(4) == "acct" else { return completion(false) }
                    TutorRegistration.acctId = value
                    Tutor.shared.initTutor(completion: { error in
                        completion(error == nil)
                    })
                })
            }
        }
    }
    
    func switchToTutorSide(_ completion: @escaping (Bool) -> Void) {
        FirebaseData.manager.fetchTutor(CurrentUser.shared.learner.uid!, isQuery: false) { tutor in
            if let tutor = tutor {
                CurrentUser.shared.tutor = tutor
                StripeService.retrieveConnectAccount(acctId: tutor.acctId, { error, account in
                    if let error = error {
                        AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                        completion(false)
                    } else if let account = account {
                        CurrentUser.shared.connectAccount = account
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
            } else {
                completion(false)
            }
        }
    }
    
    func bankErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Ok", style: .destructive) { _ in }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }

    func declineButtonAlert() {
        let alertController = UIAlertController(title: "Are You Sure?", message: "All of your progress will be deleted.", preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Ok", style: .destructive) { _ in
            self.navigationController?.popBackToMain()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
}
