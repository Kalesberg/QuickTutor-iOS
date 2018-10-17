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
        navigationController = CustomNavVC(rootViewController: controller)
        navigationController.navigationBar.isHidden = true
        guard let window = UIApplication.shared.keyWindow else { return }
        window.rootViewController = navigationController
    }
    
    private init() {}
    
}
