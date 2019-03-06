//
//  TutorPolicy.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseAuth
import Stripe
import UIKit

class TutorPolicyVC: BaseRegistrationController {
    
    let contentView: TutorPolicyVCView = {
        let view = TutorPolicyVCView()
        return view
    }()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        setupTargets()
        progressView.isHidden = true
    }
    
    func setupContentView() {
        contentView.layoutIfNeeded()
        contentView.scrollView.contentSize = CGSize(width: contentView.scrollView.frame.width, height: contentView.contentLabel.frame.height)
    }
    
    func setupTargets() {
        contentView.checkBox.addTarget(self, action: #selector(accepted), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(showIndependentTutorAgreement))
        tap.numberOfTapsRequired = 1
        contentView.independentTutorButton.addGestureRecognizer(tap)
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

    func switchToTutorSide(_ completion: @escaping (Bool) -> Void) {
        FirebaseData.manager.fetchTutor(CurrentUser.shared.learner.uid!, isQuery: false) { tutor in
            if let tutor = tutor {
                CurrentUser.shared.tutor = tutor
                Stripe.retrieveConnectAccount(acctId: tutor.acctId, { error, account in
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

    func createConnectAccount(_ completion: @escaping (Bool) -> Void) {
        Stripe.createConnectAccountToken(ssn: TutorRegistration.ssn!, line1: TutorRegistration.line1, city: TutorRegistration.city, state: TutorRegistration.state, zipcode: TutorRegistration.zipcode) { token, error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else if let token = token {
                Stripe.createConnectAccount(bankAccountToken: TutorRegistration.bankToken!, connectAccountToken: token, { error, value in
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

    func bankErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okButton = UIAlertAction(title: "Ok", style: .destructive) { _ in }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }

   @objc func accepted() {
        contentView.checkBox.isSelected = true
        displayLoadingOverlay()
        createConnectAccount { success in
            if success {
                self.switchToTutorSide({ success in
                    if success {
                        CurrentUser.shared.learner.isTutor = true
                        AccountService.shared.currentUserType = .tutor
                        self.navigationController?.pushViewController(QTTutorDashboardViewController(), animated: true)
                        let endIndex = self.navigationController?.viewControllers.endIndex
                        self.navigationController?.viewControllers.removeFirst(endIndex! - 1)
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

    func declined() {
        declineButtonAlert()
    }
    
    @objc func showIndependentTutorAgreement() {
        guard let url = URL(string: "https://www.quicktutor.com/ita.pdf") else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:]) { _ in }
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

extension NSMutableAttributedString {
    @discardableResult func regular(_ text: String, _ size: CGFloat, _ color: UIColor, _ spacing: CGFloat = 0) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Lato-Regular", size: size)!, .foregroundColor: color]
        let string = NSMutableAttributedString(string: text, attributes: attrs)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        string.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, string.length))

        append(string)

        return self
    }

    @discardableResult func bold(_ text: String, _ size: CGFloat, _ color: UIColor, _ spacing: CGFloat = 0) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Lato-Bold", size: size)!, .foregroundColor: color]
        let string = NSMutableAttributedString(string: text, attributes: attrs)
        append(string)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        string.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, string.length))

        return self
    }
}
