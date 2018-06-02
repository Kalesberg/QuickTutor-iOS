//
//  CreateAccountVC.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/28/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountVC: UIViewController {
    
    var profileImageData: Data?
    
    let profilePicButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.sentMessage
        button.layer.cornerRadius = 50
        button.clipsToBounds = true
        button.setTitle("Add Picture", for: .normal)
        return button
    }()
    
    let usernameField: PaddedTextField = {
        let field = PaddedTextField()
        field.autocapitalizationType = .none
        field.backgroundColor = .clear
        field.layer.borderColor = Colors.border.cgColor
        field.layer.borderWidth = 1.5
        field.textColor = .white
        field.tintColor = .white
        field.layer.cornerRadius = 25
        field.keyboardAppearance = .dark
        field.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        field.applyDefaultShadow()
        return field
    }()
    
    let emailField: PaddedTextField = {
        let field = PaddedTextField()
        field.autocapitalizationType = .none
        field.backgroundColor = .clear
        field.layer.borderColor = Colors.border.cgColor
        field.layer.borderWidth = 1.5
        field.textColor = .white
        field.tintColor = .white
        field.layer.cornerRadius = 25
        field.keyboardAppearance = .dark
        field.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        field.applyDefaultShadow()
        return field
    }()
    
    let passwordField: PaddedTextField = {
        let field = PaddedTextField()
        field.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
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
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Teacher", "Student"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.applyDefaultShadow()
        return segmentedControl
    }()
    
    let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
        button.backgroundColor = Colors.purple
        button.layer.cornerRadius = 25
        button.applyDefaultShadow()
        return button
    }()
    
    let hasAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Already have an account? Login", for: .normal)
        button.setTitleColor(Colors.purple, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        setupMainView()
        setupProfilePicButton()
        setupSegmentedControl()
        setupUsernameField()
        setupEmailField()
        setupPasswordField()
        setupSignInButton()
        setupNoAccountButton()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
    }
    
    private func setupProfilePicButton() {
        view.addSubview(profilePicButton)
        profilePicButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        view.addConstraint(NSLayoutConstraint(item: profilePicButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: profilePicButton, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.6, constant: 0))
        profilePicButton.addTarget(self, action: #selector(showPicturePicker), for: .touchUpInside)
    }
    
    private func setupSegmentedControl() {
        view.addSubview(segmentedControl)
        segmentedControl.anchor(top: profilePicButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 30)
    }
    
    private func setupUsernameField() {
        view.addSubview(usernameField)
        usernameField.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 50)
    }
    
    private func setupEmailField() {
        view.addSubview(emailField)
        emailField.anchor(top: usernameField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 50)
    }
    
    private func setupPasswordField() {
        view.addSubview(passwordField)
        passwordField.anchor(top: emailField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 50)
    }
    
    private func setupSignInButton() {
        view.addSubview(createAccountButton)
        createAccountButton.anchor(top: passwordField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 50)
        createAccountButton.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
    }
    
    private func setupNoAccountButton() {
        view.addSubview(hasAccountButton)
        hasAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.getBottomAnchor(), right: view.rightAnchor, paddingTop: 0, paddingLeft: 75, paddingBottom: 50, paddingRight: 75, width: 0, height: 30)
        hasAccountButton.addTarget(self, action: #selector(showLogin), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    @objc func showPicturePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @objc func showLogin() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func createAccount() {
        guard let email = emailField.text, let password = passwordField.text, let _ = usernameField.text, profileImageData != nil else { return }
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            guard let user = user, error == nil else {
                print(error.debugDescription)
                return
            }
//            self.saveUserToDatabase(user)
            Auth.auth().signIn(withEmail: email, password: password, completion: { user, _ in
                guard user != nil else { return }
                self.addNotificationSettingsToFirebase()
                self.showMessagesVC()
            })
        }
    }
    
    func addNotificationSettingsToFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let data = ["connectionRequests": true, "messages": true, "sessionRequests": true]
        Database.database().reference().child("notificationPreferences").child(uid).updateChildValues(data)
    }
}

extension CreateAccountVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("There was no image")
            return
        }
        _ = getCompressedImageDataFor(image)
        profilePicButton.setImage(image, for: .normal)
        profilePicButton.setTitle("", for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveProfileImageToFirebase(user: FirebaseAuth.User) {
        guard let image = profilePicButton.imageView?.image, let data = getCompressedImageDataFor(image) else {
            return
        }
        
//        Storage.storage().reference().child(user.uid).child("profilePic").putData(data, metadata: nil) { metadata, _ in
//            Database.database().reference().child("accounts").child(user.uid).child("profilePicUrl").setValue(metadata?.downloadURL()?.absoluteString)
//        }
    }
    
    func getCompressedImageDataFor(_ image: UIImage) -> Data? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: CGFloat(ceil(200 / image.size.width * image.size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("No context")
            return nil
        }
        imageView.layer.render(in: context)
        guard let scaledImage = UIGraphicsGetImageFromCurrentImageContext() else {
            print("No scaled image")
            return nil
        }
        UIGraphicsEndImageContext()
        guard let dataToUpload = UIImageJPEGRepresentation(scaledImage, 0.5) else {
            print("No data to upload")
            return nil
        }
        profileImageData = dataToUpload
        return dataToUpload
    }
    
    func saveUserToDatabase(_ user: FirebaseAuth.User) {
        var typeOfUser = "teacher"
        if segmentedControl.selectedSegmentIndex == 1 {
            typeOfUser = "student"
        }
        guard let username = usernameField.text else { return }
        guard let fcmToken = Messaging.messaging().fcmToken else { return }
        let values = ["type": typeOfUser, "username": username, "fcmToken": fcmToken]
        
        Database.database().reference().child("accounts").child(user.uid).updateChildValues(values)
        saveProfileImageToFirebase(user: user)
        AccountService.shared.loadUser()
    }
    
    func showMessagesVC() {
        let vc = MessagesVC()
        let navVC = CustomNavVC(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
}
