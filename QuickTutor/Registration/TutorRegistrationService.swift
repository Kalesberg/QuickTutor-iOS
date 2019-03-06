//
//  TutorRegistrationService.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class TutorRegistrationService {
    static let shared = TutorRegistrationService()
    
    var subjects = [String]()
    
    func addSubject(_ subject: String) {
        subjects.append(subject)
        NotificationCenter.default.post(name: Notifications.tutorSubjectsDidChange.name, object: nil, userInfo: nil)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("subjects").child(subject).child(uid).setValue(1)
    }
    
    func removeSubject(_ subject: String) {
        subjects = subjects.filter({ $0 != subject})
        NotificationCenter.default.post(name: Notifications.tutorSubjectsDidChange.name, object: nil, userInfo: nil)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("subjects").child(subject).child(uid).removeValue()
    }
    
    func setFeaturedSubject(_ subject: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("tutor-info").child(uid).child("sbj").setValue(subject)
        
    }
    
    func restructureTutorSubjectData() {
        Database.database().reference().child("subject")
    }
    
    private init() {
        if CurrentUser.shared.learner.isTutor {
            subjects = CurrentUser.shared.tutor.subjects ?? [String]()
        } else {
            subjects = [String]()
        }
    }
}
