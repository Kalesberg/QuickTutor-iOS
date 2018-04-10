//
//  LoginVC.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/13/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase

class LoginVC: UIViewController {
    
    let emailField: PaddedTextField = {
        let field = PaddedTextField()
        field.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.backgroundColor = .clear
        field.borderStyle = .roundedRect
        field.layer.borderColor = Colors.border.cgColor
        field.layer.borderWidth = 1.5
        field.textColor = .white
        field.tintColor = .white
        field.layer.cornerRadius = 25
        field.keyboardAppearance = .dark
        field.applyDefaultShadow()
        return field
    }()
    
    let passwordField: PaddedTextField = {
        let field = PaddedTextField()
        field.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.isSecureTextEntry = true
        field.backgroundColor = .clear
        field.layer.borderColor = Colors.border.cgColor
        field.layer.borderWidth = 1.5
        field.textColor = .white
        field.tintColor = .white
        field.layer.cornerRadius = 25
        field.keyboardAppearance = .dark
        field.applyDefaultShadow()
        return field
    }()
    
    let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign in", for: .normal)
        button.backgroundColor = Colors.purple
        button.layer.cornerRadius = 25
        button.applyDefaultShadow()
        return button
    }()
    
    let noAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Don't have an account? Sign Up", for: .normal)
        button.setTitleColor(Colors.purple, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = Colors.darkBackground
        setupEmailField()
        setupPasswordField()
        setupSignInButton()
        setupNoAccountButton()
    }
    
    private func setupEmailField() {
        view.addSubview(emailField)
        emailField.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 75, paddingBottom: 12, paddingRight: 75, width: 0, height: 50)
        view.addConstraint(NSLayoutConstraint(item: emailField, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.8, constant: 0))
    }
    
    private func setupPasswordField() {
        view.addSubview(passwordField)
        passwordField.anchor(top: emailField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 50)
    }
    
    private func setupSignInButton() {
        view.addSubview(signInButton)
        signInButton.anchor(top: passwordField.bottomAnchor, left: passwordField.leftAnchor, bottom: nil, right: passwordField.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
    }
    
    private func setupNoAccountButton() {
        view.addSubview(noAccountButton)
        noAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 75, paddingBottom: 50, paddingRight: 75, width: 0, height: 30)
        noAccountButton.addTarget(self, action: #selector(showCreateAccount), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    @objc func signIn() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            AccountService.shared.loadUser()
            self.showMessagesVC()
        }
    }
    
    func showMessagesVC() {
        let vc = MessagesVC()
        let navVC = CustomNavVC(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func showCreateAccount() {
        let vc = CreateAccountVC()
        present(vc, animated: true, completion: nil)
    }
    
}
