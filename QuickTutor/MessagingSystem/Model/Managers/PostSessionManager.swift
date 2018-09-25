//
//  PostSessionManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/29/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import Foundation

enum SessionStatus: String {
    case started
    case tipAdded
    case ratingAdded
    case reviewAdded
    case complete
}

class PostSessionManager {
    var session: Session?
    var status: SessionStatus?

    static let shared = PostSessionManager()
    private init() {}

    func setUnfinishedFlag(sessionId: String, status: SessionStatus) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard status != SessionStatus.reviewAdded else {
            Database.database().reference().child("unfinishedSessions").child(uid).child(sessionId).removeValue()
            return
        }
        Database.database().reference().child("unfinishedSessions").child(uid).child(sessionId).setValue(status.rawValue)
    }

    func checkForUnfinishedSession(completion: @escaping (String, String) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("unfinishedSessions").child(uid).observeSingleEvent(of: .childAdded) { snapshot in
            guard let value = snapshot.value as? String else { return }
            completion(snapshot.ref.key!, value)
        }
    }

    func sessionDidEnd(sessionId: String, partnerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("unfinishedSessions").child(uid).child(sessionId).setValue(SessionStatus.started.rawValue)
        Database.database().reference().child("unfinishedSessions").child(partnerId).child(sessionId).setValue(SessionStatus.started.rawValue)
    }

    func removeObservers() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("unfinishedSessions").child(uid).removeAllObservers()
    }
}
