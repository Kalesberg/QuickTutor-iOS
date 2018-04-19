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
        Database.database().reference().child("sessionStarts").child(uid).observe(.childAdded, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any],
                let startType = value["startType"] as? String,
                let initiatorId = value["startedBy"] as? String,
                let sessionType = value["sessionType"] as? String
                else { return }
            let vc = sessionType == "online" ? VideoSessionStartVC() : InpersonSessionStartVC()
            vc.sessionId = snapshot.key
            vc.initiatorId = initiatorId
            vc.startType = startType
            navigationController.navigationBar.isHidden = false
            navigationController.pushViewController(vc, animated: true)
        })
        
        Database.database().reference().child("sessionStarts").child(uid).observe(.childChanged, with: { (snapshot) in
            print("Calling second snapshot...")
            guard let value = snapshot.value as? [String: Any] else { return }
            print(snapshot.value)
            if let start = value["startAccepted"] as? Bool, let type = value["sessionType"] as? String {
                if type == "online" {
                    let vc = VideoSessionVC()
                    navigationController.pushViewController(vc, animated: true)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "manualStartAccepted"), object: nil)
                    guard let confirmedUsers = value["confirmedBy"] as? [String: Any], confirmedUsers.count == 2 else { return }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showConfirmMeetup"), object: nil)
                }
            }
            print("Value was changed...")
        })
    }
}
