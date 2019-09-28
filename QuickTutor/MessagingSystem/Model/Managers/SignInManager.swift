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
            completion()
            return
        }
        
        let typeOfUser: UserType = UserDefaults.standard.bool(forKey: "showHomePage") ? .learner : .tutor
        let vc = typeOfUser == .learner ? LearnerMainPageVC() : QTTutorDashboardViewController.controller
        
        // Get the information of categories. i.e. suggested price classes for now.
        DataService.shared.getCategoriesInfo()
        
        FirebaseData.manager.signInUserOfType(typeOfUser, uid: user.uid) { (successful) in
            guard successful else {
                RootControllerManager.shared.configureRootViewController(controller: GetStartedViewController())
                return
            }
            AccountService.shared.updateFCMTokenIfNeeded()
            CardService.shared.checkForPaymentMethod()
            RootControllerManager.shared.configureRootViewController(controller: vc)
            
            completion()
        }
    }
    
    private init() {}
}
