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
    
    let verifyEmailButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Save Email", for: .normal)
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
        addSubview(verifyEmailButton)
        verifyEmailButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(0)
            make.width.equalToSuperview()
            make.height.equalTo(68)
            make.centerX.equalToSuperview()
        }
    }
    
    func updateVerificationButtonBottomConstraint(inset: Float) {
        verifyEmailButton.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(inset)
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

class ChangeEmailVC: UIViewController {

    let contentView: ChangeEmailView = {
        let view = ChangeEmailView()
        return view
    }()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.textField.delegate = self
        setupTargets()
        setupNavBar()
        setupKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Hide the bottom tab bar and relayout views
        tabBarController?.tabBar.isHidden = true
        edgesForExtendedLayout = .bottom
        extendedLayoutIncludesOpaqueBars = true
    }
    
    func setupNavBar() {
        navigationItem.title = "Change Email"
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.textField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentView.textField.resignFirstResponder()
    }
    
    func setupKeyboardObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            contentView.updateVerificationButtonBottomConstraint(inset: 0)
        } else {
            let keyboardRectangle = keyboardFrame.cgRectValue
            var keyboardHeight = keyboardRectangle.height
            if #available(iOS 11.0, *) {
                keyboardHeight -= UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
            }
            
            let bottom = keyboardHeight > 0 ? keyboardHeight : 0
            let quickTypeBarHeight: CGFloat = 50.0
            contentView.updateVerificationButtonBottomConstraint(inset: Float(bottom - quickTypeBarHeight))
        }
    }

    @objc private func updateEmail() {
        guard let email = contentView.textField.text, email.emailRegex() else {
            AlertController.genericErrorAlertWithoutCancel(self, title: "Invalid Email", message: "")
            contentView.textField.becomeFirstResponder()
            return
        }
        
        self.updateFirebaseEmail(email)
    }
    
    private func updateFirebaseEmail(_ email: String) {
        FirebaseData.manager.updateValue(node: "account", value: ["em": email], { error in
            if let error = error {
                AlertController.genericErrorAlertWithoutCancel(self, message: error.localizedDescription)
            }
            self.changeUserSharedEmail(email)
            self.displaySavedAlertController()
        })
    }
    
    private func changeUserSharedEmail(_ email: String) {
        if let tutor = CurrentUser.shared.tutor {
            tutor.email = email
        }
        
        if let learner = CurrentUser.shared.learner {
            learner.email = email
        }
    }

    private func displaySavedAlertController() {
        let alertController = UIAlertController(title: "Saved!", message: "Your email has been updated", preferredStyle: .alert)

        present(alertController, animated: true, completion: nil)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertController.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setupTargets() {
        contentView.verifyEmailButton.addTarget(self, action: #selector(updateEmail), for: .touchUpInside)
    }
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
