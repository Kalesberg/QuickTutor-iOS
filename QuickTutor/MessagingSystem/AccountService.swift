//
//  File.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/1/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase
import Foundation

class AccountService {
    static let shared = AccountService()
    private(set) var currentUser: User!

    var currentUserType: UserType = .learner {
        didSet {
            UserDefaults.standard.set(currentUserType == .learner, forKey: "showHomePage")
        }
    }

    private init() {
        loadUser()
    }

    func loadUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DataService.shared.getUserWithUid(uid) { userIn in
            guard let user = userIn else { return }
            self.currentUser = user
        }
    }
    
    func updateFCMTokenIfNeeded() {
        if let fcmToken = Messaging.messaging().fcmToken {
            self.saveFCMToken(fcmToken)
        }
    }
    
    private func saveFCMToken(_ token: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("account").child(uid).child("fcmToken").setValue(token)
    }
}

class SessionService {
    static let shared = SessionService()
    var session: Session?
    var rating = 0

    private init() {}
}
