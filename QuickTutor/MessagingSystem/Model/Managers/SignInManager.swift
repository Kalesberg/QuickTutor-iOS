//
//  SignInManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/17/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

class SignInManager {
    static let shared = SignInManager()
    
    func handleSignIn(completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            RootControllerManager.shared.configureRootViewController(controller: SignInVC())
            completion()
            return
        }
        
        let typeOfUser: UserType = UserDefaults.standard.bool(forKey: "showHomePage") ? .learner : .tutor
        let vc = typeOfUser == .learner ? LearnerMainPageVC() : QTTutorDashboardViewController.controller // TutorMainPage()
        
        
        FirebaseData.manager.signInUserOfType(typeOfUser, uid: user.uid) { (successful) in
            guard successful else {
                RootControllerManager.shared.configureRootViewController(controller: SignInVC())
                return
            }
            AccountService.shared.updateFCMTokenIfNeeded()
            RootControllerManager.shared.configureRootViewController(controller: vc)
            completion()
        }
    }
    
    private init() {}
}
