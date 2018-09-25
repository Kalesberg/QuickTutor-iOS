//
//  CustomNavVC.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/2/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class CustomNavVC: UINavigationController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupViews()
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setupViews()
    }

    func setupViews() {
        navigationBar.barTintColor = Colors.navBarColor
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        if #available(iOS 11.0, *) {
            navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
