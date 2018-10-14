//
//  NotificationManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

enum NotificationCategory {
    case messsage, sessionsStart, sessionPause, sessionRequestAccepted, connectionRequestAccepted, sessionCancelled
}


class NotificationManager {
    
    static let shared = NotificationManager()
    
    var disabledNotificationCategories = [NotificationCategory.sessionsStart]
    var disabledNotificationForUid: String?
    
    
    func handleInAppPushNotification(userInfo: [AnyHashable: Any]) {
        let notification = PushNotification(userInfo: userInfo)
        guard SessionService.shared.session == nil else { return }
        let vc = notification.receiverAccountType == "learner" ? LearnerPageVC() : TutorPageViewController()
        RootControllerManager.shared.configureRootViewController(controller: vc)
        self.handleMessageType(notification: notification)
    }
    
    func handlePushNotification(userInfo:[AnyHashable: Any]) {
        let notification = PushNotification(userInfo: userInfo)
        guard SessionService.shared.session == nil else { return }
        let vc = notification.receiverAccountType == "learner" ? LearnerPageVC() : TutorPageViewController()
        RootControllerManager.shared.configureRootViewController(controller: vc)
        self.handleMessageType(notification: notification)
    }
    
    func handleMessageType(notification: PushNotification) {
        guard notification.category == "messages" else { return }
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
    
    func canHandle(notificationType: NotificationCategory) -> Bool {
        return disabledNotificationCategories.contains(notificationType)
    }
    
    
    
    private init() {}
}

class RootControllerManager {
    
    static let shared = RootControllerManager()
    
    func configureRootViewController(controller: UIViewController) {
        navigationController = CustomNavVC(rootViewController: controller)
        navigationController.navigationBar.isHidden = true
        guard let window = UIApplication.shared.keyWindow else { return }
        window.rootViewController = navigationController
    }
    
    private init() {}
    
}


class SignInManager {
    static let shared = SignInManager()
    
    func handleSignIn(completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            RootControllerManager.shared.configureRootViewController(controller: SignInVC())
            completion()
            return
        }
        
        let typeOfUser: UserType = UserDefaults.standard.bool(forKey: "showHomePage") ? .learner : .tutor
        let vc = typeOfUser == .learner ? LearnerPageVC() : TutorPageViewController()
        
        FirebaseData.manager.signInUserOfType(typeOfUser, uid: user.uid) { (successful) in
            guard successful else {
                RootControllerManager.shared.configureRootViewController(controller: SignInVC())
                return
            }
            AccountService.shared.updateFCMTokenIfNeeded()
            RootControllerManager.shared.configureRootViewController(controller: vc)
            completion()
        }
    }
    
    private init() {}
}
