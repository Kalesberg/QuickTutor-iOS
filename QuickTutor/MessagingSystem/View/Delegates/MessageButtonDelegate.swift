//
//  MessageButtonDelegate.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

protocol MessageButtonDelegate {
    func showConversationWithUID(_ uid: String)
}

extension MessageButtonDelegate {
    func showConversationWithUID(_ uid: String) {
        let userInfo = ["uid": uid]
        let notification = Notification(name: NSNotification.Name(rawValue: "sendMessage"), object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
}

protocol ViewProfileButtonDelegate {
    func viewProfileWithUID(_ uid: String)
}

extension ViewProfileButtonDelegate {
    func viewProfileWithUID(_ uid: String) {
        let userInfo = ["uid": uid]
        let notification = Notification(name: NSNotification.Name(rawValue: "com.qt.viewProfile"), object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
}
