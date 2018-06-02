//
//  HandlesSessionStartData.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

protocol HandlesSessionStartData {
    func listenForData()
}

extension HandlesSessionStartData {
    func listenForData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("Currently signed in user is: \(uid)")
        let sessionStartsRef = Database.database().reference().child("sessionStarts").child(uid)
        sessionStartsRef.observe(.childAdded, with: { (snapshot) in
            sessionStartsRef.removeValue()
            guard let value = snapshot.value as? [String: Any] else {
                fatalError("Error with value")
            }
            
            guard let startType = value["startType"] as? String else {
                fatalError("Error with start tyoe")
            }
            
            guard let initiatorId = value["startedBy"] as? String else {
                fatalError("Error with initiatorId")
            }
            
            guard let sessionType = value["sessionType"] as? String else {
                fatalError("Error with sessionType")
            }
            
            let vc = sessionType == "online" ? VideoSessionStartVC() : InpersonSessionStartVC()
            vc.sessionId = snapshot.key
            vc.initiatorId = initiatorId
            vc.startType = startType
            navigationController.navigationBar.isHidden = false
            navigationController.pushViewController(vc, animated: true)
        })
    }
}
