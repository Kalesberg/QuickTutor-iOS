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

            let sessionId = snapshot.key
            // remove local notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [sessionId])
            
            if QTSessionType(rawValue: sessionType) == QTSessionType.quickCalls {
                let controller = QTStartQuickCallViewController.controller
                controller.modalPresentationStyle = .overCurrentContext
                controller.sessionId = sessionId
                if let initiatorId = value["startedBy"] as? String {
                    controller.initiatorId = initiatorId
                }
                controller.sessionType = QTSessionType(rawValue: sessionType)
                controller.startType = QTSessionStartType(rawValue: startType)
                controller.parentNavController = navigationController
                
                if let topController = navigationController.topViewController {
                    navigationController.delegate = topController
                }
                navigationController.navigationBar.isHidden = true
                navigationController.present(controller, animated: false, completion: nil)
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
