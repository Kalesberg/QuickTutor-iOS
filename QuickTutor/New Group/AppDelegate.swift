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

var navigationController = UINavigationController()

func setDeviceInfo() -> (Double, Double, Double, Double) {
    
    switch UIScreen.main.bounds.height {
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		guard let gai = GAI.sharedInstance() else {
			assert(false, "Google Analytics not configured correctly")
		}
		gai.tracker(withTrackingId: "UA-121323472-1")
        //Get device info
        let (keyboardHeight, statusbarHeight, fontSize, multiplier) = setDeviceInfo()
        
        DeviceInfo.keyboardHeight = keyboardHeight
        DeviceInfo.statusbarHeight = statusbarHeight
        DeviceInfo.textFieldFontSize = fontSize
        DeviceInfo.multiplier = multiplier
        // Stripe
        STPPaymentConfiguration.shared().publishableKey = "pk_test_TtFmn5n1KhfNPgXXoGfg3O97"
        
        //White status bar throughout
        UIApplication.shared.statusBarStyle = .lightContent
        
        registerForPushNotifications(application: application)
        
        //Firebase init
        FirebaseApp.configure()
        
        //Facebook init
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = launchScreen
        window?.makeKeyAndVisible()

        handleSignIn {}
        
        return true
    }
    
    func handleSignIn(completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            configureRootViewController(controller: SignIn())
            completion()
            return
        }
        
        let typeOfUser: UserType = UserDefaults.standard.bool(forKey: "showHomePage") ? .learner : .tutor
        let vc = typeOfUser == .learner ? LearnerPageViewController() : TutorPageViewController()
        
        FirebaseData.manager.signInUserOfType(typeOfUser, uid: user.uid) { (successful) in
            guard successful else {
                self.configureRootViewController(controller: SignIn())
                completion()
                return
            }
            self.updateFCMTokenIfNeeded()
            self.configureRootViewController(controller: vc)
            completion()
        }
    }
    
    func updateFCMTokenIfNeeded() {
        if let fcmToken = Messaging.messaging().fcmToken {
            self.saveFCMToken(fcmToken)
        }
    }
    
    func configureRootViewController(controller: UIViewController) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.launchScreen.contentView.icon.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { (true) in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
                self.launchScreen.contentView.icon.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.launchScreen.contentView.icon.alpha = 0.0
            }) { (true) in
                navigationController = CustomNavVC(rootViewController: controller)
                navigationController.navigationBar.isHidden = true
                self.window?.makeKeyAndVisible()
                self.window?.rootViewController = navigationController
                self.listenForData()
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handlIncomingDynamicLink(dynamicLink)
        }
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return handled
    }
    
    func handlIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let pathComponents = dynamicLink.url?.pathComponents else { return }
        handleSignIn {
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
                vc.contentView.rightButton.isHidden = true
                vc.contentView.title.label.text = "@\(tutor.username!)"
                navigationController.pushViewController(vc, animated: true)
            })
        } else {
            FirebaseData.manager.fetchLearner(uid) { (learner) in
                guard let learner = learner else { return }
                let vc = LearnerMyProfile()
                vc.learner = learner
                vc.contentView.title.label.isHidden = true
                vc.contentView.rightButton.isHidden = true
                vc.isViewing = true
                navigationController.pushViewController(vc, animated: true)
            }
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
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
        firebaseAuth.setAPNSToken(deviceToken, type: .prod)
        
        //At time of production it will be set to .prod
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()
		
        if (firebaseAuth.canHandleNotification(userInfo)){
            print(userInfo)
        }
        guard let receiverAccountType = userInfo["receiverAccountType"] as? String else { return }
        if receiverAccountType == "learner" {
            let vc = LearnerPageViewController()
            configureRootViewController(controller: vc)
            let messagesVC = MessagesVC()
        } else {
            let vc = TutorPageViewController()
            configureRootViewController(controller: vc)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        guard let receiverAccountType = userInfo["receiverAccountType"] as? String else { return }
        if receiverAccountType == "learner" {
            let vc = LearnerPageViewController()
            configureRootViewController(controller: vc)
        } else {
            let vc = TutorPageViewController()
            configureRootViewController(controller: vc)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        OnlineStatusService.shared.resignActive()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        OnlineStatusService.shared.makeActive()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        OnlineStatusService.shared.makeActive()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
        return extensionPointIdentifier != UIApplicationExtensionPointIdentifier.keyboard
    }
}
