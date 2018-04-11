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
        return (216.0, 20, 22, 1.15)
    default:
        return (0, 0, 0, 0)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
        
        application.registerForRemoteNotifications()
        
        //Firebase init
        FirebaseApp.configure()
        
        //Facebook init
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        window = UIWindow(frame: UIScreen.main.bounds)
        
        //Firebase check
        if Auth.auth().currentUser != nil {
            //create SignInClass to handle everything before user is able to sign in.
			
			_ = SignInHandler.init({ (error) in
				if error != nil {
					print(error!)
					self.window?.makeKeyAndVisible()
					let controller = SignIn()
					navigationController = CustomNavVC(rootViewController: controller)
					navigationController.navigationBar.isHidden = true
					self.window?.rootViewController = navigationController
				} else {
					print("Sign In Handler Completed.")
					print("Grabbing customer data...")
					Stripe.stripeManager.retrieveCustomer({ (error) in
						if let error = error {
							print(error.localizedDescription)
						}
						print("Retrieved customer.")
						self.window?.makeKeyAndVisible()
					})
					
					let controller = TutorAddSubjects()
                    AccountService.shared.currentUserType = .learner
					navigationController = CustomNavVC(rootViewController: controller)
					navigationController.navigationBar.isHidden = true
					self.window?.rootViewController = navigationController
				}
			})
        } else {
            let controller = SignIn()
            navigationController = CustomNavVC(rootViewController: controller)
            navigationController.navigationBar.isHidden = true
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController = navigationController
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return handled
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to auth.
        let firebaseAuth = Auth.auth()
        
        //At development time we use .sandbox
        firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
        
        //At time of production it will be set to .prod
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()
        
        if (firebaseAuth.canHandleNotification(userInfo)){
            print(userInfo)
            return
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
        if extensionPointIdentifier == UIApplicationExtensionPointIdentifier.keyboard {
            return false
        }
        
        return true
    }
}
