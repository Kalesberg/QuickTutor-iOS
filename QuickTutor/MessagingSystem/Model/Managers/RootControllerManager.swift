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
            if nil == CurrentUser.shared.learner.interests {
                setupHookModel()
            } else {
                setupLearnerTabBar(controller: controller)
            }
        } else if controller is QTTutorDashboardViewController { // TutorMainPage
            setupTutorTabBar(controller: controller)
        } else {
            setupDefaultConfiguration(controller: controller)
        }
    }
    
    func setupDefaultConfiguration(controller: UIViewController) {
        navigationController = CustomNavVC(rootViewController: controller)
        navigationController.setNavigationBarHidden(true, animated: false)
        guard let window = UIApplication.shared.keyWindow else { return }
        window.rootViewController = navigationController
    }
    
    func setupLearnerTabBar(controller: UIViewController) {
        AccountService.shared.currentUserType = .learner
        let tab = LearnerTabBarController()
        setupDefaultConfiguration(controller: tab)
    }
    
    func setupHookModel() {
        let selectCategoriesVC = QTSelectCategoriesViewController(nibName: String(describing: QTSelectCategoriesViewController.self), bundle: nil)
        let hookModelNC = QTHookModelNavigationController(rootViewController: selectCategoriesVC)
        hookModelNC.hookModelDelegate = self
        guard let window = UIApplication.shared.keyWindow else { return }
        window.rootViewController = hookModelNC
    }
    
    func setupTutorTabBar(controller: UIViewController) {
        AccountService.shared.currentUserType = .tutor
        let tab = TutorTabBarController()
        setupDefaultConfiguration(controller: tab)
    }
    
    private init() {}
    
}

extension RootControllerManager: QTHookModelNavigationControllerDelegate {
    func didFinishHookModel(_ viewController: UIViewController) {
        setupLearnerTabBar(controller: LearnerMainPageVC())
    }
}
