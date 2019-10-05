//
//  LearnerTabBarViewController.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/26/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class LearnerTabBarController: BaseTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let home = UINavigationController(rootViewController: LearnerMainPageVC())
        home.tabBarItem = ESTabBarItem(QTTabBarItemContentView(), image: UIImage(named: "homeTabBarIcon"), selectedImage: UIImage(named: "homeTabBarIcon"))
        let saved = UINavigationController(rootViewController: SavedTutorsVC())
        saved.tabBarItem = ESTabBarItem(QTTabBarItemContentView(), image: UIImage(named: "savedTabBarIcon"), selectedImage: UIImage(named: "savedTabBarIcon"))
        let sessions = UINavigationController(rootViewController: LearnerSessionsVC())
        sessions.tabBarItem = ESTabBarItem(QTTabBarItemContentView(), image: UIImage(named: "sessionsTabBarIcon"), selectedImage: UIImage(named: "sessionsTabBarIcon"))
        sessions.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        let messages = UINavigationController(rootViewController: MessagesVC())
        messages.tabBarItem = ESTabBarItem(QTTabBarItemContentView(), image: UIImage(named: "chatTabBarIcon"), selectedImage: UIImage(named: "chatTabBarIcon"))
        messages.navigationBar.barTintColor = Colors.newNavigationBarBackground
        messages.navigationBar.backgroundColor = Colors.newNavigationBarBackground
        let profile = UINavigationController(rootViewController: ProfileVC())
        profile.tabBarItem = ESTabBarItem(QTTabBarItemContentView(), image: UIImage(named: "profileTabBarIcon"), selectedImage: UIImage(named: "profileTabBarIcon"))
        let controllers = [home, saved, sessions, messages, profile]

        for vc in controllers {
            vc.navigationBar.barTintColor = Colors.newNavigationBarBackground
            vc.navigationBar.tintColor = .white
            vc.view.backgroundColor = Colors.newScreenBackground
            vc.navigationBar.isTranslucent = false
            vc.navigationBar.isOpaque = false
            vc.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: Fonts.createBoldSize(18)]
            if #available(iOS 11.0, *) {
                vc.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: Fonts.createBoldSize(34)]
            }
        }
        viewControllers = controllers
        viewControllers?.forEach {
            if let navController = $0 as? UINavigationController {
                let _ = navController.topViewController?.view
            } else {
                let _ = $0.view.description
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleQuickSearchTapped(_:)), name: NotificationNames.LearnerMainFeed.quickSearchTapped, object: nil)
        
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            NotificationCenter.default.removeObserver(self)
        }
        super.didMove(toParent: parent)
    }
    
    @objc
    func handleQuickSearchTapped(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // TODO: Uncomment the following statement when merge with learner discover scren.
            /*
            if let viewControllers = self.viewControllers, let controller = viewControllers[1] as? QTLearnerDiscoverViewController {
                self.selectedViewController = controller
                controller.onClickBtnSearch(controller.view)
            }
             */
            
            if let viewControllers = self.viewControllers {
                self.selectedViewController = viewControllers[1]
            }
        }
    }
}
