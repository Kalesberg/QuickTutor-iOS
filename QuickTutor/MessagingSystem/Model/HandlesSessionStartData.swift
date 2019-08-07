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
                print("Error with value")
                return
            }

            guard let startType = value["startType"] as? String else {
                print("Error with start tyoe")
                return
            }

            guard let sessionType = value["sessionType"] as? String else {
                print("Error with sessionType")
                return
            }

            let sessionId = snapshot.key
            // remove local notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [sessionId])
            
            if QTSessionType(rawValue: sessionType) == QTSessionType.quickCalls {
                let controller = QTStartQuickCallViewController.controller
                controller.sessionId = sessionId
                if let initiatorId = value["startedBy"] as? String {
                    controller.initiatorId = initiatorId
                }
                controller.sessionType = QTSessionType(rawValue: sessionType)
                controller.startType = QTSessionStartType(rawValue: startType)
                controller.parentNavController = navigationController
                
                navigationController.navigationBar.isHidden = true
                navigationController.present(controller, animated: true, completion: nil)
            } else {
                let vc = QTStartSessionViewController.controller
                vc.sessionId = sessionId
                if let initiatorId = value["startedBy"] as? String {
                    vc.initiatorId = initiatorId
                }
                vc.sessionType = QTSessionType(rawValue: sessionType)
                vc.startType = QTSessionStartType(rawValue: startType)
                navigationController.navigationBar.isHidden = false
                navigationController.pushViewController(vc, animated: true)
            }
        })
    }

    func removeDataObserver() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let sessionStartsRef = Database.database().reference().child("sessionStarts").child(uid)
        sessionStartsRef.removeAllObservers()
    }
}
