//
//  ChangeEmail.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import FirebaseAuth
import SwiftKeychainWrapper
import UIKit

class ChangeEmailView: UIView, Keyboardable {
    var keyboardComponent = ViewComponent()

    let textField: NoPasteTextField = {
        let field = NoPasteTextField()
        field.tintColor = Colors.purple
        field.font = Fonts.createSize(20)
        field.isEnabled = true
        field.textColor = Colors.grayText
        field.autocapitalizationType = .none
        field.keyboardType = .emailAddress
        return field
    }()
    
    let subtitle: UILabel = {
        let label = UILabel()
        label.text = "Enter new Email address"
        label.font = Fonts.createBoldSize(18)
        label.numberOfLines = 2
        label.textColor = .white
        return label
    }()
    
    let updateEmailButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Send verification code", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.purple
        return button
    }()
    
    var line = UIView()
    
    func setupViews() {
        setupMainView()
        addKeyboardView()
        setupSubtitleLabel()
        setupTextField()
        setupLine()
        setupVerificationButton()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupTextField() {
        addSubview(textField)
        textField.anchor(top: subtitle.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
    }
    
    func setupSubtitleLabel() {
        addSubview(subtitle)
        subtitle.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 30)
    }
    
    func setupLine() {
        textField.addSubview(line)
        line.backgroundColor = Colors.gray
        line.snp.makeConstraints { make in
            make.bottom.equalTo(textField).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(1)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupVerificationButton() {
        addSubview(updateEmailButton)
        updateEmailButton.snp.makeConstraints { make in
            make.bottom.equalTo(keyboardView.snp.top)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.08)
            make.centerX.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class ChangeEmailTextField: InteractableView, Interactable {
    var textField = NoPasteTextField()
    var line = UIView()

    override func configureView() {
        addSubview(textField)
        addSubview(line)
        super.configureView()

        textField.isEnabled = true
        textField.font = Fonts.createSize(18)
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.tintColor = .white
        textField.keyboardType = .emailAddress
        line.backgroundColor = .white

        applyConstraints()
    }

    override func applyConstraints() {
        textField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(30)
        }

        line.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}

class ChangeEmailVC: UIViewController {

    let contentView: ChangeEmailView = {
        let view = ChangeEmailView()
        return view
    }()

    override func loadView() {
        view = contentView
    }

    var verificationId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.textField.delegate = self
        setupTargets()
        setupNavBar()
    }
    
    func setupNavBar() {
        navigationItem.title = "Change Email"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"newBackButton"), style: .plain, target: self, action: #selector(onBack))
    }
    
    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.textField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentView.textField.resignFirstResponder()
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

    private func getUserCredentialsAlert() {
        let phoneNumber = CurrentUser.shared.learner.phone.cleanPhoneNumber()

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationId, error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else if let id = verificationId {
                self.verificationId = id
                self.displayPhoneVerificationAlert(message: "Please enter the verifcation code sent to: \(CurrentUser.shared.learner.phone.formatPhoneNumber())")
            } else {
                AlertController.genericErrorAlert(self, title: "Error", message: "Something went wrong, please try again.")
            }
        }
    }

    private func displaySavedAlertController() {
        let alertController = UIAlertController(title: "Saved!", message: "Your email update has been saved", preferredStyle: .alert)

        present(alertController, animated: true, completion: nil)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertController.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setupTargets() {
        contentView.updateEmailButton.addTarget(self, action: #selector(sendVerificationCode), for: .touchUpInside)
    }
    
    @objc func sendVerificationCode() {
        guard let email = contentView.textField.text, email.emailRegex() else {
            AlertController.genericErrorAlert(self, title: "Invalid Email", message: "")
            contentView.textField.becomeFirstResponder()
            return
        }
        getUserCredentialsAlert()
    }

//    override func handleNavigation() {
//        if touchStartView is PhoneAuthenicationActionCancel {
//            dismissPhoneAuthenticationAlert()
//        } else if touchStartView is PhoneAuthenicationAction {
//            if let view = self.view.viewWithTag(321) as? PhoneAuthenticationAlertView {
//                guard let verificationCode = view.verificationTextField.text, !verificationCode.contains("—") else { return }
//                reauthenticateUser(code: verificationCode) { error in
//                    if let error = error {
//                        view.errorLabel.isHidden = false
//                        view.errorLabel.text = error.localizedDescription
//                    } else {
//                        if AccountService.shared.currentUserType == .learner {
//                            CurrentUser.shared.learner.email = self.contentView.textField.text!
//                        } else {
//                            CurrentUser.shared.tutor.email = self.contentView.textField.text!
//                            CurrentUser.shared.learner.email = self.contentView.textField.text!
//                        }
//                        FirebaseData.manager.updateValue(node: "account", value: ["em": self.contentView.textField.text!], { error in
//                            if let error = error {
//                                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
//                            }
//                        })
//                        self.dismissPhoneAuthenticationAlert()
//                        self.displaySavedAlertController()
//                    }
//                }
//            }
//        }
//    }
}

extension ChangeEmailVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxlength = 40
        guard let text = textField.text else { return true }
        let length = text.count + string.count - range.length

        if length <= maxlength { return true }
        else { return false }
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        return true
    }

    func textFieldDidBeginEditing(_: UITextField) {
        contentView.textField.becomeFirstResponder()
    }
}
