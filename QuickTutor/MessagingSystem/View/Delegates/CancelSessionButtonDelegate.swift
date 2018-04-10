//
//  CancelSessionButtonDelegate.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

protocol CancelSessionButtonDelegate {
    func cancelSession(id: String)
}

extension CancelSessionButtonDelegate {
    func cancelSession(id: String) {
        let userInfo = ["sessionId": id]
        let notification = Notification(name: NSNotification.Name(rawValue: "cancelSession"), object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
}
