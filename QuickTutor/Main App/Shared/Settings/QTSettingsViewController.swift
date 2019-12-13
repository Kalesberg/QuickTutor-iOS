//
//  QTSettingsViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 3/3/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookCore
import FacebookLogin

class QTSettingsViewController: UIViewController, QTSettingsNavigation {

    // MARK: - variables
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var twitterButton: QTCustomButton!
    @IBOutlet weak var facebookButton: QTCustomButton!
    @IBOutlet weak var instagramButton: QTCustomButton!
    @IBOutlet weak var showMeView: UIView!
    @IBOutlet weak var showMeSwitch: QTCustomView!
    @IBOutlet weak var switchOffImageView: QTCustomImageView!
    @IBOutlet weak var switchOnImageView: QTCustomImageView!
    @IBOutlet weak var linkFacebookView: UIView!
    
    @IBOutlet weak var showFacebookView: UIView!
    @IBOutlet weak var imgFacebook: UIImageView!
    @IBOutlet weak var lblFacebookName: UILabel!
    @IBOutlet weak var btnDisconnectFacebook: UIButton!
    
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var guidelinesReadButton: UIButton!
    @IBOutlet weak var safetyReadButton: UIButton!
    
    var isShowMe: Bool = false
    
    private let loginManager = LoginManager()
    
    // MARK: - static functions
    static var controller: QTSettingsViewController {
        return QTSettingsViewController(nibName: String(describing: QTSettingsViewController.self), bundle: nil)
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        
        // Change social button colors.
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = instagramButton.bounds
        gradientLayer.colors = [Colors.wheat,
                                Colors.orange,
                                Colors.pink,
                                Colors.brightPurple,
                                Colors.warmBlue].map({$0.cgColor})
        gradientLayer.locations = [0, 0.27, 0.52, 0.75, 1]
        gradientLayer.transform = CATransform3DMakeRotation(CGFloat.pi * 1.25, 0, 0, 1)
        instagramButton.layer.insertSublayer(gradientLayer, at: 0)
        instagramButton.layer.cornerRadius = 30
        instagramButton.layer.masksToBounds = true
        instagramButton.bringSubviewToFront(instagramButton.imageView!)
        
        let twitterImage = twitterButton.image(for: .normal)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        twitterButton.setImage(twitterImage, for: .normal)
        twitterButton.tintColor = UIColor.white
        
        let facebookImage = facebookButton.image(for: .normal)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        facebookButton.setImage(facebookImage, for: .normal)
        facebookButton.tintColor = UIColor.white
        
        // add dimming
        rateButton.setupTargets()
        guidelinesReadButton.setupTargets()
        safetyReadButton.setupTargets()
        twitterButton.setupTargets()
        facebookButton.setupTargets()
        instagramButton.setupTargets()
        
        
        // Update location
        locationTextField.attributedPlaceholder = NSAttributedString.init(string: "Select",
                                                                          attributes: [.foregroundColor : Colors.registrationGray])
        locationTextField.isEnabled = false
        
        // Add gestures.
        locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidLocationViewTap(_:))))
        locationView.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleDidLinkFacebookViewTap(_:)))
        tapGestureRecognizer.minimumPressDuration = 0
        linkFacebookView.addGestureRecognizer(tapGestureRecognizer)
        
        showMeSwitch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowMeSwitchTap(_:))))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        
        if AccountService.shared.currentUserType == .learner {
            locationView.isHidden = false
            showMeView.isHidden = true
            locationTextField.text = CurrentUser.shared.learner.region ?? "United States"
        } else if let tutor = CurrentUser.shared.tutor {
            locationView.isHidden = false
            showMeView.isHidden = false
            isShowMe = tutor.isVisible
            showMeSwitchOn(isShowMe)
            locationTextField.text = tutor.region ?? "United States"
        }
        
        updateFacebookInfoView()
    }
    
    private func updateFacebookInfoView() {
        if nil == AccountService.shared.currentUser { return }
        
        if let facebook = AccountService.shared.currentUser.facebook {
            linkFacebookView.superview?.isHidden = true
            showFacebookView.superview?.isHidden = false
            
            if let imageUrl = facebook["imageUrl"] {
                imgFacebook.sd_setImage(with: URL(string: imageUrl), placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
            }
            if let strFBName = facebook["name"] {
                lblFacebookName.text = strFBName
            }
            btnDisconnectFacebook.isHidden = AccountService.shared.currentUser.isFacebookLogin || 1 == Auth.auth().currentUser?.providerData.count
        } else {
            if let provider = Auth.auth().currentUser?.providerData.first(where: { "facebook.com" == $0.providerID }) {
                var facebookInfo: [String: String] = [:]
                if let email = provider.email {
                    facebookInfo["email"] = email
                }
                if let name = provider.displayName {
                    facebookInfo["name"] = name
                }
                if let photoUrl = provider.photoURL?.absoluteString {
                    facebookInfo["imageUrl"] = photoUrl
                }
                
                FirebaseData.manager.updateFacebook(CurrentUser.shared.learner.uid, facebook: facebookInfo) { error in
                    if nil == error {
                        AccountService.shared.currentUser.facebook = facebookInfo
                        self.updateFacebookInfoView()
                    }
                }
            } else {
                linkFacebookView.superview?.isHidden = false
                showFacebookView.superview?.isHidden = true
            }
        }
    }
    
    // MARK: - actions
    @IBAction func onRateButtonClicked(_ sender: Any) {
        SocialMedia.rateApp(appUrl: "itms-apps://itunes.apple.com/app/id1388092698", webUrl: "", completion: { _ in
        })
    }
    
    @IBAction func onCommunityReadButtonClicked(_ sender: Any) {
        let next = WebViewVC()
        next.navigationItem.title = "Community Guidelines"
        next.url = "https://www.quicktutor.com/community/community-guidelines"
        next.loadAgreementPdf()
        navigationController?.pushViewController(next, animated: true)
    }
    
    @IBAction func onSafetyReadButtonClicked(_ sender: Any) {
        let next = WebViewVC()
        next.navigationItem.title = "User Safety"
        next.url = "https://www.quicktutor.com/community/user-safety"
        next.loadAgreementPdf()
        navigationController?.pushViewController(next, animated: true)
    }
    
    @IBAction func onClickLogoutButtonClicked(_ sender: Any) {
        goToSignInVC()
    }
    
    @IBAction func deleteAccountButtonClicked(_ sender: Any) {
        navigationController?.pushViewController(QTCloseAccountInfoViewController.controller, animated: true)
    }
    
    @objc
    func handleShowMeSwitchTap(_ sender: Any) {
        isShowMe = !isShowMe
        showMeSwitchOn(isShowMe)
        CurrentUser.shared.tutor.isVisible = isShowMe
        FirebaseData.manager.updateTutorVisibility(uid: CurrentUser.shared.learner.uid!, status: isShowMe ? 0 : 1)
        
        var message = "Currently, you are not visible in search results."
        if isShowMe {
            message = "Currently, you are visible in search results."
        }
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        present(alertController, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertController.dismiss(animated: true)
        }
    }
    
    @IBAction func onClickBtnDisconnectFacebook(_ sender: Any) {
        guard let currentUser = Auth.auth().currentUser,
            nil != AccountService.shared.currentUser.facebook else { return }
        
        let alert = UIAlertController(title: "Disconnect Facebook",
                                      message: "Are you sure you want to disconnect your facebook account?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Disconnect", style: .destructive) { _ in
            currentUser.unlink(fromProvider: "facebook.com") { user, error in
                if let error = error {
                    let alert = UIAlertController(title: "Link Facebook Error",
                                                  message: error.localizedDescription,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true) {
                        self.loginManager.logOut()
                    }
                    return
                }
                
                FirebaseData.manager.updateFacebook(CurrentUser.shared.learner.uid, facebook: nil) { error in
                    if nil == error {
                        AccountService.shared.currentUser.facebook = nil
                        self.updateFacebookInfoView()
                    }
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    func handleDidLocationViewTap(_ recognizer: UITapGestureRecognizer) {
        let controller = QTLocationsViewController.controller
        controller.address = locationTextField.text
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleDidTwitterViewTap(_ sender: Any) {
        SocialMedia.rateApp(appUrl: "twitter://user?screen_name=QuickTutor", webUrl: "https://twitter.com/QuickTutor", completion: { _ in
        })
    }
    
    @IBAction func handleDidFacebookViewTap(_ sender: Any) {
        SocialMedia.rateApp(appUrl: "fb://profile/1346980958682540", webUrl: "https://www.facebook.com/QuickTutor/", completion: { _ in
        })
    }
    
    @IBAction func handleDidInstagramViewTap(_ sender: Any) {
        SocialMedia.rateApp(appUrl: "instagram://user?username=QuickTutor", webUrl: "https://www.instagram.com/quicktutor/", completion: { _ in
        })
    }
    
    @objc
    func handleDidLinkFacebookViewTap(_ recognizer: UILongPressGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            linkFacebookView.didTouchDown()
            break
        case .changed:
            break
        case .ended:
            linkFacebookView.didTouchUp()
            loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { (result) in
                switch result {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success:
                    guard let accessToken = AccessToken.current?.tokenString else { break }
                    
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
                    Auth.auth().currentUser?.link(with: credential) { authResult, error in
                        if let error = error {
                            let alert = UIAlertController(title: "Link Facebook Error",
                                                          message: error.localizedDescription,
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            self.present(alert, animated: true) {
                                self.loginManager.logOut()
                            }
                            return
                        }
                        
                        self.getFacebookProfile() { dicUserData in
                            guard let dicUserData = dicUserData else { return }
                            
                            var facebookInfo: [String: String] = [:]
                            if let email = dicUserData["email"] as? String {
                                facebookInfo["email"] = email
                            }
                            if let name = dicUserData["name"] as? String, !name.isEmpty {
                                facebookInfo["name"] = name
                            } else if let firstName = dicUserData["firstname"] as? String,
                                let lastName = dicUserData["lastname"] as? String,
                                !firstName.isEmpty, !lastName.isEmpty {
                                facebookInfo["name"] = "\(firstName) \(lastName)"
                            } else {
                                facebookInfo["name"] = ""
                            }
                            if let userId = dicUserData["id"] as? String {
                                facebookInfo["id"] = userId
                                facebookInfo["imageUrl"] = "https://graph.facebook.com/\(userId)/picture?type=large"
                            }
                            FirebaseData.manager.updateFacebook(CurrentUser.shared.learner.uid, facebook: facebookInfo) { error in
                                if nil == error {
                                    AccountService.shared.currentUser.facebook = facebookInfo
                                    self.updateFacebookInfoView()
                                }
                            }
                        }
                    }
                }
            }
            break
        default:
            linkFacebookView.didTouchUp()
            break
        }
    }
    
    private func getFacebookProfile(completion: @escaping ([String: Any]?) -> ()) {
        let params = ["fields": "id, name, first_name, last_name, email", "redirect": "false"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params)
        graphRequest.start { _, response, error in
            if let error = error {
                print("error in graph request:", error)
                completion(nil)
            } else {
                if let responseDictionary = response as? [String: Any] {
                    print("Facebook response dictionary", responseDictionary)
                    completion(responseDictionary)
                }
            }
        }
    }
    
    // MARK: - private functions
    func setupNavBar() {
        navigationItem.title = "Settings"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func showMeSwitchOn(_ isOn: Bool) {
        if isOn {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                self.switchOnImageView.alpha = 1.0
                self.switchOffImageView.alpha = 0.0
            }, completion: { finished in
                
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                self.switchOnImageView.alpha = 0.0
                self.switchOffImageView.alpha = 1.0
            }, completion: { finished in
                
            })
        }
    }
}

protocol QTSettingsNavigation {
    
}

extension QTSettingsNavigation {
    func goToSignInVC() {
        let alertController = UIAlertController(title: "Are You Sure?", message: "You will be logged out.", preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            do {
                if let userId = Auth.auth().currentUser?.uid {
                    UserStatusService.shared.updateUserStatus(userId, status: .offline)
                    AccountService.shared.saveFCMToken(nil)
                }
                // Facebook Logout
                try Auth.auth().signOut()
                // Firebase Logout
                LoginManager().logOut()
                // Remove shared user object
                CurrentUser.shared.logout()
                AccountService.shared.logout()
                
                RootControllerManager.shared.configureRootViewController(controller: GetStartedViewController())
            } catch {
                print("Error signing out")
            }
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        
        guard let current = UIApplication.getPresentedViewController() else { return }
        current.present(alertController, animated: true, completion: nil)
    }
}
