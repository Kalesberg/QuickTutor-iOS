//
//  NotificationManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

enum NotificationCategory: String {
    case message = "messages"
    case sessionsStart = "sessionStart"
    case sessionPause = "sessionPause"
    case sessionRequestAccepted = "sessionRequestAccepted"
    case connectionRequestAccepted = "connectionRequestAccepted"
    case sessionCancelled = "sessionCancelled"
}

class NotificationManager {
    
    static let shared = NotificationManager()
    
    var notificationsEnabled = true
    var messageNotificationsEnabled = true
    var disabledNotificationForUid: String?
    
    func handleInAppPushNotification(userInfo: [AnyHashable: Any]) {
        let notification = PushNotification(userInfo: userInfo)
        guard SessionService.shared.session == nil else { return }
        guard canHandle(notificationType: .message) else { return }
        self.handleMessageType(notification: notification)
    }
    
    func handlePushNotification(userInfo:[AnyHashable: Any]) {
        let notification = PushNotification(userInfo: userInfo)
        guard SessionService.shared.session == nil else { return }
        self.handleMessageType(notification: notification)
    }
    
    func handleMessageType(notification: PushNotification) {
        guard notification.category == .message else { return }
        if let type = notification.receiverAccountType {
            AccountService.shared.currentUserType = UserType(rawValue: type)!
        }
        SignInManager.shared.handleSignIn {
            DataService.shared.getUserOfOppositeTypeWithId(notification.partnerId()) { (userIn) in
                guard let user = userIn else { return }
                let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
                vc.receiverId = notification.partnerId()
                vc.chatPartner = user
                navigationController.pushViewController(vc, animated: true)
            }
        }
    }
    
    func enableAllNotifcations() {
        messageNotificationsEnabled = true
        notificationsEnabled = true
    }
    
    func disableAllNotifications() {
        messageNotificationsEnabled = false
        notificationsEnabled = false
    }
    
    func canHandle(notificationType: NotificationCategory) -> Bool {
        guard notificationsEnabled else { return false }
        if notificationType == .message {
            return messageNotificationsEnabled
        } else {
            return true
        }
    }
    
    func enableAllConversationNotifications() {
        messageNotificationsEnabled = true
    }
    
    func disableAllConversationNotifications() {
        messageNotificationsEnabled = false
    }
    
    func enableConversationNotificationsFor(uid: String) {
        disabledNotificationForUid = nil
    }
    
    func disableConversationNotificationsFor(uid: String) {
        disabledNotificationForUid = uid
    }
    
    private init() {}
}

