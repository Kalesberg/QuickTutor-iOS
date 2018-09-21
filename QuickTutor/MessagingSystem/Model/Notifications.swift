//
//  Notifications.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

struct Notifications {
    static let test = Notification(name: Notification.Name(rawValue: "com.quicktutor.close"))
    static let didEnterBackground = Notification(name: Notification.Name(rawValue: "com.quickTutor.didEnterBackground"))
    static let didEnterForeground = Notification(name: Notification.Name(rawValue: "com.quickTutor.didEnterForeground"))
    static let willTerminate = Notification(name: Notification.Name(rawValue: "com.quickTutor.willTerminate"))
    static let showOverlay =  Notification(name: Notification.Name(rawValue: "com.quickTutor.showOverlay"))
    static let hideOverlay =  Notification(name: Notification.Name(rawValue: "com.quickTutor.hideOverlay"))
}

struct PushNotification {
    var identifier: String
    var category: String
    var senderId: String?
    var receiverId: String?
    var senderAccountType: String?
    var receiverAccountType: String?
    var sessionId: String?
    
    func partnerId() -> String {
        guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
        guard let senderIdIn = senderId, let receiverIdIn = receiverId else { return "" }
        return senderId == uid ? receiverIdIn : senderIdIn
    }
    
    init(userInfo: [AnyHashable: Any]) {
        identifier = userInfo["identifier"] as? String ?? ""
        category = userInfo["category"] as? String ?? "sessions"
        senderId = userInfo["senderId"] as? String
        receiverId = userInfo["receiverId"] as? String
        senderAccountType = userInfo["senderAccountType"] as? String
        receiverAccountType = userInfo["receiverAccountType"] as? String
        sessionId = userInfo["sessionId"] as? String
    }
    
}
