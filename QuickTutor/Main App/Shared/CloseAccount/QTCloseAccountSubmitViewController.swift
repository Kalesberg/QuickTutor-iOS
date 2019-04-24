//
//  QTCloseAccountSubmitViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 4/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import PlaceholderTextView
import FirebaseAuth

class QTCloseAccountSubmitViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var reasonView: QTCustomView!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var commentTextView: PlaceholderTextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    static var controller: QTCloseAccountSubmitViewController {
        return QTCloseAccountSubmitViewController()
    }
    
    // Parameter
    var reason: String!
    var closeAccountType: QTCloseAccountType!
    
    let reasons = ["I have privacy concerns.", "I don't find QuickTutor useful.", "QuickTutor is confusing to use.", "I don't have a reason."]
    var shown = false
    private var verificationId: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Close Account"
        setupTargets()
        setupReasonTable()
        setupCommentTextView()
        
        self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        updateReason(reason)
    }

    // MARK: - Actions
    @IBAction func onSubmitButtonClicked(_ sender: Any) {
        getUserCredentialsAlert()
    }
    
    @objc
    func handleKeyboardShow(_ notification: Notification) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut, animations: nil)
        animator.addAnimations {
            self.submitButtonBottom.constant = CGFloat(DeviceInfo.keyboardHeight)
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    @objc
    func handleKeyboardHide(_ notification: Notification) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut, animations: nil)
        animator.addAnimations {
            self.submitButtonBottom.constant = 20
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    // MARK: - Functions
    func setupTargets() {
        
        hideKeyboardWhenTappedAround()
        
        reasonView.isUserInteractionEnabled = true
        reasonView.setupTargets { state in
            if state == .ended {
                self.shown = !self.shown
                self.showReasonTable(show: self.shown)
            }
        }
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardShow(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func setupReasonTable() {
        
        // Register tableviewcells.
        tableView.register(QTCloseAccountReasonTableViewCell.nib, forCellReuseIdentifier: QTCloseAccountReasonTableViewCell.reuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set heights of cells.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 57
        
        tableView.layer.cornerRadius = 3
        tableView.clipsToBounds = true
    }
    
    func setupCommentTextView() {
        commentTextView.layer.cornerRadius = 3
        commentTextView.layer.borderColor = Colors.gray.cgColor
        commentTextView.layer.borderWidth = 1
        commentTextView.font = Fonts.createSize(14)
        commentTextView.keyboardAppearance = .dark
        commentTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    func showReasonTable(show: Bool) {
        tableView.layoutIfNeeded()
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut, animations: nil)
        animator.addAnimations {
            self.tableViewHeight.constant = show ? 228 : 0
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: show ? CGFloat.pi * 3 / 2 : CGFloat.pi / 2)
            self.arrowImageView.overlayTintColor(color: UIColor.white)
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    func updateReason(_ reason: String) {
        self.reason = reason
        reasonLabel.text = reason
    }
    
    private func getTutorAccount(_ completion: @escaping ([String]) -> Void) {
        FirebaseData.manager.fetchTutor(CurrentUser.shared.learner.uid, isQuery: false) { tutor in
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
    
    private func removeUser() {
        if CurrentUser.shared.learner.isTutor == false {
            self.removeLearner()
        } else {
            if DeleteAccount.type {
                self.removeTutorAccount()
            } else {
                self.removeBothAccounts()
            }
        }
        
    }
    
    private func removeLearner() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        FirebaseData.manager.removeLearnerAccount(uid: CurrentUser.shared.learner.uid, reason: reason, { error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else {
                currentUser.delete { error in
                    if let error = error {
                        let errorCode = AuthErrorCode(rawValue: error._code)
                        if errorCode == AuthErrorCode.requiresRecentLogin {
                            self.getUserCredentialsAlert()
                        }
                    } else {
                        self.navigationController?.pushViewController(SignInVC(), animated: false)
                    }
                }
            }
        })
    }
    
    private func removeTutorAccount() {
        displayLoadingOverlay()
        getTutorAccount { subcategories in
            FirebaseData.manager.removeTutorAccount(uid: CurrentUser.shared.learner.uid, reason: self.reason, subcategory: subcategories, message: self.commentTextView.text ?? "", { error in
                if let error = error {
                    self.dismissOverlay()
                    AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                } else {
                    self.dismissOverlay()
                    CurrentUser.shared.learner.isTutor = false
                    self.navigationController?.pushViewController(LearnerMainPageVC(), animated: true)
                }
            })
        }
    }
    
    private func removeBothAccounts() {
        guard let currentUser = Auth.auth().currentUser else { return }
        getTutorAccount({ subcategories in
            FirebaseData.manager.removeBothAccounts(uid: CurrentUser.shared.learner.uid, reason: self.reason, subcategory: subcategories, message: self.commentTextView.text ?? "", { error in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                } else {
                    currentUser.delete { error in
                        if let error = error {
                            let errorCode = AuthErrorCode(rawValue: error._code)
                            if errorCode == AuthErrorCode.requiresRecentLogin {
                                self.getUserCredentialsAlert()
                            }
                        } else {
                            self.navigationController?.pushViewController(SignInVC(), animated: false)
                        }
                    }
                }
            })
        })
    }

    private func getUserCredentialsAlert() {
        guard let phone = CurrentUser.shared.learner.phone, !phone.isEmpty else {
            removeUser()
            return
        }
        let phoneNumber = phone.cleanPhoneNumber()
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationId, error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else if let id = verificationId {
                self.verificationId = id
                self.displayPhoneVerificationAlert(message: "Please enter the verifcation code sent to: \(CurrentUser.shared.learner.phone.formatPhoneNumber())", self)
            } else {
                AlertController.genericErrorAlert(self, title: "Error", message: "Something went wrong, please try again.")
            }
        }
    }
    
    private func reauthenticateUser(code: String, completion: @escaping (Error?) -> Void) {
        guard let id = self.verificationId else { return }
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: id, verificationCode: code)
        let currentUser = Auth.auth().currentUser
        currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { _, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        })
    }

}


extension QTCloseAccountSubmitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateReason(reasons[indexPath.row])
        shown = false
        showReasonTable(show: shown)
    }
}

extension QTCloseAccountSubmitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let cell = tableView.dequeueReusableCell(withIdentifier: QTCloseAccountReasonTableViewCell.reuseIdentifier, for: indexPath) as? QTCloseAccountReasonTableViewCell {
            cell.setData(reason: reasons[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
        
        cell.selectionStyle = .none
        return cell
    }
}

extension QTCloseAccountSubmitViewController: AlertAction {
    func cancelAlertPressed() {
        dismissPhoneAuthenticationAlert()
    }
    
    func verifyAlertPressed(code: String) {
        if code.isEmpty || !code.contains("—") {
            return
        }
        reauthenticateUser(code: code) {error in
            if let error = error {
                self.dismissPhoneAuthenticationAlert()
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else {
                self.removeUser()
                self.dismissPhoneAuthenticationAlert()
            }
        }
    }
}
