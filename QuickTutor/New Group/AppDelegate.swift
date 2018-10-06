//
//  AppDelegate.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/16/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import UserNotifications
import FBSDKCoreKit
import Stripe
import AVFoundation
import Crashlytics

var navigationController = UINavigationController()

func setDeviceInfo() -> (Double, Double, Double, Double) {
    
    switch UIScreen.main.bounds.height {
	case 896:
		return (301.0, 40, 28, 0.95)
    case 812:
        return (291.0, 40, 28, 1.0)
    case 736:
        return (226.0, 20, 28, 1.05)
    case 667:
        return (216.0, 20, 24, 1.1)
    case 568:
        return (216.0, 20, 24, 1.15)
    case 480:
        return (216.0, 0, 18, 1.15)
    default:
        return (0, 0, 0, 0)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, HandlesSessionStartData, MessagingDelegate {
    
    var window: UIWindow?
    let launchScreen = LaunchScreen()
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//		guard let gai = GAI.sharedInstance() else {
//            return true
//		}
//		gai.tracker(withTrackingId: "UA-121323472-1")
        //Get device info
        let (keyboardHeight, statusbarHeight, fontSize, multiplier) = setDeviceInfo()
        
        DeviceInfo.keyboardHeight = keyboardHeight
        DeviceInfo.statusbarHeight = statusbarHeight
        DeviceInfo.textFieldFontSize = fontSize
        DeviceInfo.multiplier = multiplier
        // Stripe
        STPPaymentConfiguration.shared().publishableKey = "pk_test_TtFmn5n1KhfNPgXXoGfg3O97"
        
        registerForPushNotifications(application: application)
        
        //Firebase init
        FirebaseApp.configure()
        
        //Facebook init
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = launchScreen
        window?.makeKeyAndVisible()

        handleSignIn {
            self.proceedWithCameraAccess()
            self.proceedWithMicrophoneAccess()
        }
        
        return true
    }
    
    func checkForUnfinishedSessions() {
        PostSessionManager.shared.checkForUnfinishedSession { (sessionId, sessionStatus) in
            DataService.shared.getSessionById(sessionId, completion: { (session) in
                SessionService.shared.session = session
                let vc = SessionReview()
                vc.session = session
                vc.sessionId = sessionId
                vc.costOfSession = session.cost
                vc.partnerId = session.partnerId()
                vc.runTime = session.runTime
                vc.subject = session.subject
                navigationController.pushViewController(vc, animated: true)
            })
        }
    }
	
    func checkForInProgressSessions() {
        InProgressSessionManager.shared.checkForSessions { (sessionId) in
            DataService.shared.getSessionById(sessionId, completion: { (session) in
                if session.type == "online" {
                    let vc = VideoSessionVC()
                    vc.sessionId = sessionId
                    navigationController.pushViewController(vc, animated: true)
                } else {
                  let vc = InPersonSessionVC()
                    vc.sessionId = sessionId
                    navigationController.pushViewController(vc, animated: true)
                }
            })
        }
    }
    
    func proceedWithCameraAccess()  {
        AVCaptureDevice.requestAccess(for: .video) { success in
        }
    }
    
    func proceedWithMicrophoneAccess() {
        AVCaptureDevice.requestAccess(for: .audio) { success in
        }
    }
    
    func handleSignIn(completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            configureRootViewController(controller: SignInVC(), completion: {
                
            })
            completion()
            return
        }
        
        let typeOfUser: UserType = UserDefaults.standard.bool(forKey: "showHomePage") ? .learner : .tutor
        let vc = typeOfUser == .learner ? LearnerPageVC() : TutorPageViewController()
        
        FirebaseData.manager.signInUserOfType(typeOfUser, uid: user.uid) { (successful) in
            guard successful else {
                self.configureRootViewController(controller: SignInVC(), completion: {
                    
                })
                completion()
                return
            }
            self.updateFCMTokenIfNeeded()
            self.configureRootViewController(controller: vc, completion: {
                
            })
            completion()
        }
    }
    
    func updateFCMTokenIfNeeded() {
        if let fcmToken = Messaging.messaging().fcmToken {
            self.saveFCMToken(fcmToken)
        }
    }
    
    func configureRootViewController(controller: UIViewController, completion: @escaping() -> Void) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.launchScreen.contentView.icon.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { (true) in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
                self.launchScreen.contentView.icon.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.launchScreen.contentView.icon.alpha = 0.0
            }) { (true) in
                navigationController = CustomNavVC(rootViewController: SignInVC())
                navigationController.navigationBar.isHidden = true
                self.window?.makeKeyAndVisible()
                self.window?.rootViewController = navigationController
                completion()
                self.removeDataObserver()
                self.listenForData()
                self.checkForUnfinishedSessions()
                self.checkForInProgressSessions()
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handlIncomingDynamicLink(dynamicLink)
        }
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return handled
    }
    
    func handlIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        if Auth.auth().currentUser == nil {
            handleSignIn {
                self.navigateUsingPathComponents(dynamicLink: dynamicLink)
            }
        } else {
            navigateUsingPathComponents(dynamicLink: dynamicLink)
        }
    }
    
    func navigateUsingPathComponents(dynamicLink: DynamicLink) {
        guard let pathComponents = dynamicLink.url?.pathComponents else { return }
        if pathComponents.count < 2  {
            self.handleDynamicLinkNavigation(uid: pathComponents[0])
        } else {
            self.handleDynamicLinkNavigation(uid: pathComponents[1])
        }
    }
    
    func handleDynamicLinkNavigation(uid: String) {
        showProfileWithUid(uid)
    }
    
    func showProfileWithUid(_ uid: String) {
        let type = AccountService.shared.currentUserType
        
        if type == .learner {
            FirebaseData.manager.fetchTutor(uid, isQuery: false, { (tutor) in
                guard let tutor = tutor else { return }
                let vc = TutorMyProfile()
                vc.tutor = tutor
                vc.isViewing = true
                vc.contentView.rightButton.isHidden = true
                vc.contentView.title.label.text = tutor.username
                navigationController.pushViewController(vc, animated: true)
            })
        } else {
            FirebaseData.manager.fetchLearner(uid) { (learner) in
                guard let learner = learner else { return }
                let vc = LearnerMyProfileVC()
                vc.learner = learner
                vc.isViewing = true
                vc.contentView.title.label.isHidden = true
                vc.contentView.rightButton.isHidden = true
                vc.isViewing = true
                navigationController.pushViewController(vc, animated: true)
            }
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingUrl = userActivity.webpageURL {
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingUrl, completion: { [weak self] (link, erorr) in
                guard let stongSelf = self else { return }
                if let dynamicLink = link, let _ = dynamicLink.url {
                    stongSelf.handlIncomingDynamicLink(dynamicLink)
                }
            })
            return linkHandled
        }
        return false
    }
    
    private func registerForPushNotifications(application: UIApplication) {
        print("Attempting to register for push notifications")
        Messaging.messaging().delegate = self
        
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            guard error == nil else {
                print("User did not grant permission:", error.debugDescription)
                return
            }
            print("Access granted")
        }
        application.registerForRemoteNotifications()
    }
    
    private func saveFCMToken(_ token: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("account").child(uid).child("fcmToken").setValue(token)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to auth.
        let firebaseAuth = Auth.auth()
        
        //At development time we use .sandbox
        firebaseAuth.setAPNSToken(deviceToken, type: .unknown)
        
        //At time of production it will be set to .prod
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()
        guard application.applicationState != UIApplication.State.active else { return }
        if (firebaseAuth.canHandleNotification(userInfo)){
            print(userInfo)
        }
        handlePushNotification(userInfo: userInfo)
    }
    
    func handlePushNotification(userInfo:[AnyHashable: Any]) {
        let notification = PushNotification(userInfo: userInfo)
        guard SessionService.shared.session == nil else { return }
        let vc = notification.receiverAccountType == "learner" ? LearnerPageVC() : TutorPageViewController()
        configureRootViewController(controller: vc) {
            self.handleMessageType(notification: notification)
        }
    }
    
    func handleMessageType(notification: PushNotification) {
        guard notification.category == "messages" else { return }
        if let type = notification.receiverAccountType {
            AccountService.shared.currentUserType = UserType(rawValue: type)!
        }
        DataService.shared.getUserOfOppositeTypeWithId(notification.partnerId()) { (userIn) in
            guard let user = userIn else { return }
            let vc = ConversationVC(collectionViewLayout: UICollectionViewFlowLayout())
            vc.receiverId = notification.partnerId()
            vc.chatPartner = user
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        guard let receiverAccountType = userInfo["receiverAccountType"] as? String else { return }
        if receiverAccountType == "learner" {
            let vc = LearnerPageVC()
            configureRootViewController(controller: vc, completion: {
                
            })
        } else {
            let vc = TutorPageViewController()
            configureRootViewController(controller: vc, completion: {
                
            })
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        OnlineStatusService.shared.resignActive()
        NotificationCenter.default.post(Notifications.didEnterBackground)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        BackgroundSoundManager.shared.start()
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        OnlineStatusService.shared.makeActive()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        OnlineStatusService.shared.makeActive()
        NotificationCenter.default.post(Notifications.didEnterForeground)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        NotificationCenter.default.post(name: Notifications.willTerminate.name, object: nil)
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        return extensionPointIdentifier != UIApplication.ExtensionPointIdentifier.keyboard
    }
}
