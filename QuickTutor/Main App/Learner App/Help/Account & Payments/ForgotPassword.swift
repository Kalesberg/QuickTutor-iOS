//
//  ForgotPassword.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class ForgotPasswordView : MainLayoutHeader {
    
    var forgotPasswordBody = SectionBody()
    var forgotPasswordButton = ForgotPasswordButton()
    
    override func configureView() {
        addSubview(forgotPasswordBody)
        addSubview(forgotPasswordButton)
        super.configureView()
        
        title.label.text = "Help"
        header.text = "I forgot my password"
        
        forgotPasswordBody.text = "If you have forgotten your password, you can visit our password rest link below. You’ll have to enter your email address or your mobile number linked with your QuickTutor account.\n\nWe will email you within a few minutes. This email will include a link to create a new password. If you do not utilize the link within 10 minutes, you have to start over to receive a new link.\n\nTo maintain security on your account, create a unique password and do not share it with others. QuickTutor customer support will never ask for your password. "
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        forgotPasswordBody.constrainSelf(top: header.snp.bottom)
        
        forgotPasswordButton.snp.makeConstraints { (make) in
            make.top.equalTo(forgotPasswordBody.snp.bottom).offset(20)
            make.width.equalTo(forgotPasswordBody)
            make.centerX.equalToSuperview()
        }
    }
}


class HelpScrollView : BaseScrollView {
    
    override func handleNavigation() {
        
    }
    
}


class ForgotPasswordButton : InteractableView, Interactable {
    
    var label = UILabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        label.text = "Forgot your password?"
        label.font = Fonts.createBoldSize(18)
        label.textColor = UIColor(red: 130/255, green: 106/255, blue: 191/255, alpha: 1.0)
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func touchStart() {
        label.alpha = 0.7
    }
    
    func didDragOff() {
        label.alpha = 1.0
    }

}


class ForgotPassword : BaseViewController {
    
    override var contentView: ForgotPasswordView {
        return view as! ForgotPasswordView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = ForgotPasswordView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        if(touchStartView == contentView.forgotPasswordButton) {
            Auth.auth().sendPasswordReset(withEmail: CurrentUser.shared.learner.email, completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else{
                    self.alertMessage()
                }
            })
        }
    }
    private func alertMessage() {
        let alertController = UIAlertController(title: "Check your Email", message: "We have sent a password reset form to:\n\(CurrentUser.shared.learner.email)", preferredStyle: .actionSheet)

        let cancel = UIAlertAction(title: "Ok", style: .cancel) { (alert) in
            alertController.dismiss(animated: true, completion: nil)
        }
    
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
}
