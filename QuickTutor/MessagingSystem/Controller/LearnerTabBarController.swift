//
//  LearnerTabBarViewController.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/26/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class LearnerTabBarController: BaseTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let home = UINavigationController(rootViewController: LearnerMainPageVC())
        home.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeTabBarIcon"), selectedImage: UIImage(named: "homeTabBarIcon"))
        let sessions = UINavigationController(rootViewController: LearnerSessionsVC())
        sessions.tabBarItem = UITabBarItem(title: "Sessions", image: UIImage(named: "sessionsTabBarIcon"), selectedImage: UIImage(named: "sessionsTabBarIcon"))
        let messages = UINavigationController(rootViewController: MessagesVC())
        messages.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(named: "chatTabBarIcon"), selectedImage: UIImage(named: "chatTabBarIcon"))
        messages.navigationBar.barTintColor = Colors.newBackground
        messages.navigationBar.backgroundColor = Colors.newBackground
        let profile = UINavigationController(rootViewController: ProfileVC())
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileTabBarIcon"), selectedImage: UIImage(named: "profileTabBarIcon"))
        let controllers = [home, sessions, messages, profile]

        for vc in controllers {
            vc.navigationBar.barTintColor = Colors.darkBackground
            vc.navigationBar.isTranslucent = false
            vc.navigationBar.isOpaque = false
        }
        viewControllers = controllers
    }
}
