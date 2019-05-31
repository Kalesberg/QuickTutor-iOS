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
        tabBar.barTintColor = Colors.newNavigationBarBackground
        tabBar.tintColor = .qtAccentColor
        tabBar.isOpaque = false
        tabBar.isTranslucent = false
        tabBar.backgroundColor = Colors.newNavigationBarBackground
        selectedIndex = 0
        
        tabBar.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: -10), radius: 10)
    }
}

extension UITabBarController {
    func adjustBadgePosition(tabBarItemView: UIView) {
        for badgeView in tabBarItemView.subviews {
            if NSStringFromClass(badgeView.classForCoder) == "_UIBadgeView" {
                badgeView.layer.transform = CATransform3DIdentity
                badgeView.layer.transform = CATransform3DMakeTranslation(1.0, 8.0, 1.0)
            }
        }
    }
}

class TutorTabBarController: BaseTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let home = UINavigationController(rootViewController: QTTutorDashboardViewController.controller) // TutorMainPage()
        home.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "dashboardTabIcon"), selectedImage: UIImage(named: "dashboardTabIcon"))
        home.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        home.navigationBar.barTintColor = Colors.newNavigationBarBackground
        home.navigationBar.backgroundColor = Colors.newNavigationBarBackground
        let sessions = UINavigationController(rootViewController: TutorSessionsVC())
        sessions.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "sessionsTabBarIcon"), selectedImage: UIImage(named: "sessionsTabBarIcon"))
        sessions.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        let messages = UINavigationController(rootViewController: MessagesVC())
        messages.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "chatTabBarIcon"), selectedImage: UIImage(named: "chatTabBarIcon"))
        messages.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        messages.navigationBar.barTintColor = Colors.newNavigationBarBackground
        messages.navigationBar.backgroundColor = Colors.newNavigationBarBackground
        let profile = UINavigationController(rootViewController: ProfileVC())
        profile.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "profileTabBarIcon"), selectedImage: UIImage(named: "profileTabBarIcon"))
        profile.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        let controllers = [home, sessions, messages, profile]
        
        for vc in controllers {
            vc.navigationBar.barTintColor = Colors.newNavigationBarBackground
            vc.navigationBar.backgroundColor = Colors.newNavigationBarBackground
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
