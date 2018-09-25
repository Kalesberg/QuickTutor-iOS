//
//  HandlesSessionStartData.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import Foundation

protocol HandlesSessionStartData {
    func listenForData()
    func removeDataObserver()
}

extension HandlesSessionStartData {
    func listenForData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("Currently signed in user is: \(uid)")
        let sessionStartsRef = Database.database().reference().child("sessionStarts").child(uid)
        sessionStartsRef.observe(.childAdded, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                fatalError("Error with value")
            }

            guard let startType = value["startType"] as? String else {
                fatalError("Error with start tyoe")
            }

            guard let sessionType = value["sessionType"] as? String else {
                fatalError("Error with sessionType")
            }

            let vc = sessionType == "online" ? VideoSessionStartVC() : InpersonSessionStartVC()
            vc.sessionId = snapshot.key

            if let initiatorId = value["startedBy"] as? String {
                vc.initiatorId = initiatorId
            }
            vc.startType = startType
            navigationController.navigationBar.isHidden = false
            navigationController.pushViewController(vc, animated: true)
        })
    }

    func removeDataObserver() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let sessionStartsRef = Database.database().reference().child("sessionStarts").child(uid)
        sessionStartsRef.removeAllObservers()
    }
}
