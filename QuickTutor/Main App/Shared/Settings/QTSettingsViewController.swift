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
    @IBOutlet weak var twitterView: QTCustomView!
    @IBOutlet weak var twitterIconView: UIImageView!
    @IBOutlet weak var facebookView: QTCustomView!
    @IBOutlet weak var facebookImageView: UIImageView!
    @IBOutlet weak var instagramView: QTCustomView!
    @IBOutlet weak var instagramImageView: UIImageView!
    @IBOutlet weak var showMeView: UIView!
    @IBOutlet weak var showMeSwitch: QTCustomView!
    @IBOutlet weak var switchOffImageView: QTCustomImageView!
    @IBOutlet weak var switchOnImageView: QTCustomImageView!
    @IBOutlet weak var linkFacebookView: UIView!
    
    var isShowMe: Bool = false
    
    // MARK: - static functions
    static func loadView() -> QTSettingsViewController {
        return QTSettingsViewController(nibName: String(describing: QTSettingsViewController.self), bundle: nil)
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        
        // Change social button colors.
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = instagramView.bounds
        gradientLayer.colors = [Colors.wheat,
                                Colors.orange,
                                Colors.pink,
                                Colors.brightPurple,
                                Colors.warmBlue].map({$0.cgColor})
        gradientLayer.locations = [0, 0.27, 0.52, 0.75, 1]
        gradientLayer.transform = CATransform3DMakeRotation(CGFloat.pi * 1.25, 0, 0, 1)
        instagramView.layer.insertSublayer(gradientLayer, at: 0)
        instagramView.layer.cornerRadius = 30.0
        instagramView.clipsToBounds = true
        
        twitterIconView.image = twitterIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        twitterIconView.tintColor = UIColor.white
        facebookImageView.image = facebookImageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        facebookImageView.tintColor = UIColor.white
        
        // Update location
        locationTextField.attributedPlaceholder = NSAttributedString.init(string: "Select",
                                                                          attributes: [.foregroundColor : Colors.registrationGray])
        locationTextField.isEnabled = false
        
        // Add gestures.
        locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidLocationViewTap(_:))))
        locationView.isUserInteractionEnabled = true
        
        twitterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidTwitterViewTap(_:))))
        twitterView.isUserInteractionEnabled = true
        
        instagramView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidInstagramViewTap(_:))))
        instagramView.isUserInteractionEnabled = true
        
        facebookView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidFacebookViewTap(_:))))
        facebookView.isUserInteractionEnabled = true
        
        linkFacebookView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidLinkFacebookViewTap(_:))))
        
        showMeSwitch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowMeSwitchTap(_:))))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        
        if AccountService.shared.currentUserType == .learner {
            locationView.isHidden = true
            showMeView.isHidden = true
        } else {
            locationView.isHidden = false
            showMeView.isHidden = false
            isShowMe = CurrentUser.shared.tutor.isVisible
            showMeSwitchOn(isShowMe)
            locationTextField.text = CurrentUser.shared.tutor.location != nil ? CurrentUser.shared.tutor.region : ""
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
        goToCloseAccountVC()
    }
    
    @objc
    func handleShowMeSwitchTap(_ sender: Any) {
        isShowMe = !isShowMe
        showMeSwitchOn(isShowMe)
        CurrentUser.shared.tutor.isVisible = isShowMe
        FirebaseData.manager.updateTutorVisibility(uid: CurrentUser.shared.learner.uid!, status: isShowMe ? 0 : 1)
    }
    
    @objc
    func handleDidLocationViewTap(_ recognizer: UITapGestureRecognizer) {
        let controller = QTLocationsViewController.loadView()
        controller.address = CurrentUser.shared.tutor.region
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc
    func handleDidTwitterViewTap(_ recognizer: UITapGestureRecognizer) {
        SocialMedia.rateApp(appUrl: "twitter://user?screen_name=QuickTutor", webUrl: "https://twitter.com/QuickTutor", completion: { _ in
        })
    }
    
    @objc
    func handleDidFacebookViewTap(_ recognizer: UITapGestureRecognizer) {
        SocialMedia.rateApp(appUrl: "fb://profile/1346980958682540", webUrl: "https://www.facebook.com/QuickTutorApp/", completion: { _ in
        })
    }
    
    @objc
    func handleDidInstagramViewTap(_ recognizer: UITapGestureRecognizer) {
        SocialMedia.rateApp(appUrl: "instagram://user?username=QuickTutor", webUrl: "https://www.instagram.com/quicktutor/", completion: { _ in
        })
    }
    
    @objc
    func handleDidLinkFacebookViewTap(_ recognizer: UITapGestureRecognizer) {
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (result) in
            switch result {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success:
                let credential = FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
                Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { (authResult, error) in
                    print("Facebook linked")
                })
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
    func goToCloseAccountVC() {
        navigationController.pushViewController(CloseAccountVC(), animated: true)
    }
    
    func goToSignInVC() {
        let alertController = UIAlertController(title: "Are You Sure?", message: "You will be logged out.", preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                navigationController.pushViewController(SignInVC(), animated: false)
                navigationController.viewControllers.removeFirst(navigationController.viewControllers.endIndex - 1)
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