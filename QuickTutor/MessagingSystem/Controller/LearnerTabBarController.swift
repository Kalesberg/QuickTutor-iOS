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
        home.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "homeTabBarIcon"), selectedImage: UIImage(named: "homeTabBarIcon"))
        home.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        let saved = UINavigationController(rootViewController: SavedTutorsVC())
        saved.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "savedTabBarIcon"), selectedImage: UIImage(named: "savedTabBarIcon"))
        saved.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        let sessions = UINavigationController(rootViewController: LearnerSessionsVC())
        sessions.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "sessionsTabBarIcon"), selectedImage: UIImage(named: "sessionsTabBarIcon"))
        sessions.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        let messages = UINavigationController(rootViewController: MessagesVC())
        messages.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "chatTabBarIcon"), selectedImage: UIImage(named: "chatTabBarIcon"))
        messages.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        messages.navigationBar.barTintColor = Colors.newBackground
        messages.navigationBar.backgroundColor = Colors.newBackground
        let profile = UINavigationController(rootViewController: ProfileVC())
        profile.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "profileTabBarIcon"), selectedImage: UIImage(named: "profileTabBarIcon"))
        profile.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        let controllers = [home, saved, sessions, messages, profile]

        for vc in controllers {
            vc.navigationBar.barTintColor = Colors.darkBackground
            vc.navigationBar.tintColor = .white
            vc.view.backgroundColor = Colors.darkBackground
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
