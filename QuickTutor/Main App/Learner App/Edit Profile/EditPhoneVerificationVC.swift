//
//  EditPhoneVerification.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import FirebaseAuth
import FirebaseDatabase

class EditPhoneVerificationVC: VerificationVC {
    
    var phoneNumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accessoryView.nextButton.setTitle("SAVE", for: .normal)
    }
    override func createCredential(_ verificationCode: String) {
        if verificationCode.count == 6 {
            let verificationId = UserDefaults.standard.value(forKey: "reCredential")
            let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId! as! String, verificationCode: verificationCode)
            updatePhoneNumber(credential)
        }
    }
    
    func updatePhoneNumber(_ credential: PhoneAuthCredential) {
        Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { error in
            if let error = error {
                print("ZACH", error.localizedDescription)
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else {
                CurrentUser.shared.learner.phone = self.phoneNumber
                FirebaseData.manager.updateValue(node: "account", value: ["phn": CurrentUser.shared.learner.phone.cleanPhoneNumber()], { error in
                    if let error = error {
                        AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                    }
                })
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
}
