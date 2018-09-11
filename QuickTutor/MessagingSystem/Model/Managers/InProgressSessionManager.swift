//
//  InProgressSessionManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

class InProgressSessionManager {
    
    static let shared = InProgressSessionManager()
    
    func checkForSessions(completion: @escaping(String) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("inProgressSessions").child(uid).observeSingleEvent(of: .childAdded) { (snapshot) in
//            guard let value = snapshot.value as? Int else { return }
            completion(snapshot.key)
        }
    }
    
    func markSessionAsInProgress(sessionId: String, partnerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("inProgressSessions").child(uid).child(sessionId).setValue(1)
        Database.database().reference().child("inProgressSessions").child(partnerId).child(sessionId).setValue(1)
    }
    
    func removeSessionFromInProgress(sessionId: String, partnerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("inProgressSessions").child(uid).child(sessionId).removeValue()
        Database.database().reference().child("inProgressSessions").child(partnerId).child(sessionId).removeValue()
    }
    
    func removeObservers() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("inProgressSessions").child(uid).removeAllObservers()
    }
    
    private init() {}
}