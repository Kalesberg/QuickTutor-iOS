//
//  BaseRegistrationController.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class BaseRegistrationController: UIViewController {
    
    let accessoryView: RegistrationAccessoryView = {
        let view = RegistrationAccessoryView()
        return view
    }()
    
    let progressView: ProgressView = {
        let view = ProgressView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        accessoryView.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
    }
    
    func setupNavBar() {
        navigationController?.view.backgroundColor = Colors.darkBackground
        navigationController?.navigationBar.barTintColor = Colors.darkBackground
        navigationController?.navigationBar.backgroundColor = Colors.darkBackground
        navigationController?.navigationBar.isOpaque = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        setupProgressView()
    }
    
    func setupProgressView() {
        progressView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: progressView)
    }
}
