//
//  RootControllerManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/17/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class RootControllerManager {
    
    static let shared = RootControllerManager()
    
    func configureRootViewController(controller: UIViewController) {
        if controller is LearnerMainPageVC {
            setupLearnerTabBar(controller: controller)
        } else if controller is TutorMainPage {
            setupTutorTabBar(controller: controller)
        } else {
            setupDefaultConfiguration(controller: controller)
        }

    }
    
    func setupDefaultConfiguration(controller: UIViewController) {
        navigationController = CustomNavVC(rootViewController: controller)
        navigationController.navigationBar.isHidden = true
        guard let window = UIApplication.shared.keyWindow else { return }
        window.rootViewController = navigationController
    }
    
    func setupLearnerTabBar(controller: UIViewController) {
        AccountService.shared.currentUserType = .learner
        let tab = UITabBarController()
        let typeOfUser: UserType = UserDefaults.standard.bool(forKey: "showHomePage") ? .learner : .tutor
        let home = UINavigationController(rootViewController: LearnerMainPageVC())
        home.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeTabBarIcon"), selectedImage: UIImage(named: "homeTabBarIcon"))
        let sessions = UINavigationController(rootViewController: LearnerSessionsVC())
        sessions.tabBarItem = UITabBarItem(title: "Sessions", image: UIImage(named: "sessionsTabBarIcon"), selectedImage: UIImage(named: "sessionsTabBarIcon"))
        let messages = UINavigationController(rootViewController: MessagesVC())
        messages.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(named: "chatTabBarIcon"), selectedImage: UIImage(named: "chatTabBarIcon"))
        messages.navigationBar.barTintColor = Colors.newBackground
        messages.navigationBar.backgroundColor = Colors.newBackground
        let profile = UINavigationController(rootViewController: ProfileVC())
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileTabBarIcon"), selectedImage: UIImage(named: "profileTabBarIcon"))
        let controllers = [home, sessions, messages, profile]
        tab.tabBar.barTintColor = Colors.registrationDark
        tab.tabBar.tintColor = .white
        tab.tabBar.isOpaque = false
        tab.tabBar.isTranslucent = false
        tab.tabBar.backgroundColor = Colors.registrationDark


        for vc in controllers {
//            vc.tabBarItem.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
            vc.navigationBar.barTintColor = Colors.currentUserColor()
            vc.navigationBar.isTranslucent = false
            vc.navigationBar.isOpaque = false
        }
        tab.setViewControllers(controllers, animated: false)
        tab.selectedIndex = 0
        
        setupDefaultConfiguration(controller: tab)
    }
    
    func getLearnerControllers() {
        
    }
    
    func getTutorControllers() {
        
    }
    
    func setupTutorTabBar(controller: UIViewController) {
        AccountService.shared.currentUserType = .tutor
        let tab = UITabBarController()
        let home = UINavigationController(rootViewController: TutorMainPage())
        home.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(named: "dashboardTabIcon"), selectedImage: UIImage(named: "dashboardTabIcon"))
        home.navigationBar.barTintColor = Colors.newBackground
        home.navigationBar.backgroundColor = Colors.newBackground
        let sessions = UINavigationController(rootViewController: TutorSessionsVC())
        sessions.tabBarItem = UITabBarItem(title: "Sessions", image: UIImage(named: "sessionsTabBarIcon"), selectedImage: UIImage(named: "sessionsTabBarIcon"))
        let messages = UINavigationController(rootViewController: MessagesVC())
        messages.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(named: "chatTabBarIcon"), selectedImage: UIImage(named: "chatTabBarIcon"))
        messages.navigationBar.barTintColor = Colors.newBackground
        messages.navigationBar.backgroundColor = Colors.newBackground
        let profile = UINavigationController(rootViewController: ProfileVC())
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileTabBarIcon"), selectedImage: UIImage(named: "profileTabBarIcon"))
        let controllers = [home, sessions, messages, profile]
        tab.tabBar.barTintColor = Colors.registrationDark
        tab.tabBar.tintColor = .white
        tab.tabBar.isOpaque = false
        tab.tabBar.isTranslucent = false
        tab.tabBar.backgroundColor = Colors.registrationDark
        
        
        for vc in controllers {
            //            vc.tabBarItem.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
            vc.navigationBar.barTintColor = Colors.currentUserColor()
            vc.navigationBar.isTranslucent = false
            vc.navigationBar.isOpaque = false
        }
        tab.setViewControllers(controllers, animated: false)
        tab.selectedIndex = 0
        
        setupDefaultConfiguration(controller: tab)
    }
    
    private init() {}
    
}

//TODO: Unread message functionality
//let circle = UIView()
//circle.backgroundColor = Colors.notificationRed
//circle.layer.borderColor = Colors.currentUserColor().cgColor
//circle.layer.borderWidth = 2
//circle.layer.cornerRadius = 7
//circle.isHidden = true
//circle.layer.zPosition = .greatestFiniteMagnitude
//navbar.addSubview(circle)
//circle.anchor(top: messagesButton.topAnchor, left: nil, bottom: nil, right: messagesButton.rightAnchor, paddingTop: -1, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 14, height: 14)
//bringSubviewToFront(circle)
//DataService.shared.checkUnreadMessagesForUser { hasUnreadMessages in
//    circle.isHidden = !hasUnreadMessages
//}
