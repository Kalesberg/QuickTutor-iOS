//
//  File.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/1/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Foundation
import Firebase

class AccountService {
    static let shared = AccountService()
    private(set) var currentUser: User!
    
    private init() {
        loadUser()
    }
    
    func loadUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DataService.shared.getUserWithUid(uid) { (userIn) in
            guard let user = userIn else { return }
            self.currentUser = user
        }
    }    
}
