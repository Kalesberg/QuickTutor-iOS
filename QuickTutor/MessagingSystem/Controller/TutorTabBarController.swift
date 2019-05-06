//
//  TutorTabBarViewController.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/26/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = Colors.registrationDark
        tabBar.tintColor = .white
        tabBar.isOpaque = false
        tabBar.isTranslucent = false
        tabBar.backgroundColor = Colors.registrationDark
        selectedIndex = 0
    }
}

class TutorTabBarController: BaseTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let home = UINavigationController(rootViewController: QTTutorDashboardViewController.controller) // TutorMainPage()
        home.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(named: "dashboardTabIcon"), selectedImage: UIImage(named: "dashboardTabIcon"))
        home.navigationBar.barTintColor = Colors.newBackground
        home.navigationBar.backgroundColor = Colors.newBackground
        let sessions = UINavigationController(rootViewController: TutorSessionsVC())
        sessions.tabBarItem = UITabBarItem(title: "Sessions", image: UIImage(named: "sessionsTabBarIcon"), selectedImage: UIImage(named: "sessionsTabBarIcon"))
        let messages = UINavigationController(rootViewController: MessagesVC())
        messages.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(named: "chatTabBarIcon"), selectedImage: UIImage(named: "chatTabBarIcon"))
        messages.navigationBar.barTintColor = Colors.newBackground
        messages.navigationBar.backgroundColor = Colors.newBackground
        let profile = UINavigationController(rootViewController: ProfileVC())
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileTabBarIcon"), selectedImage: UIImage(named: "profileTabBarIcon"))
        let controllers = [home, sessions, messages, profile]
        
        
        for vc in controllers {
            vc.navigationBar.barTintColor = Colors.purple
            vc.navigationBar.tintColor = .white
            vc.navigationBar.isTranslucent = false
            vc.navigationBar.isOpaque = false
            vc.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: Fonts.createBoldSize(18)]
            if #available(iOS 11.0, *) {
                vc.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: Fonts.createBoldSize(34)]
            }
        }
        viewControllers = controllers
    }
}
