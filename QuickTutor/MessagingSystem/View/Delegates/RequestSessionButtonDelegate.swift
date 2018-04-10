//
//  RequestSessionButtonDelegate.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

protocol RequestSessionButtonDelegate {
    func requestSession(_ uid: String)
}

extension RequestSessionButtonDelegate {
    func requestSession(_ uid: String) {
        let userInfo = ["uid": uid]
        let notification = Notification(name: NSNotification.Name(rawValue: "requestSession"), object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
}
