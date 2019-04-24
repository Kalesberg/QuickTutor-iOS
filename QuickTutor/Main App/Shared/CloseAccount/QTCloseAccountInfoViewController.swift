//
//  QTCloseAccountInfoViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 4/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTCloseAccountInfoViewController: UIViewController {

    // MARK: - Properties
    static var controller: QTCloseAccountInfoViewController {
        return QTCloseAccountInfoViewController(nibName: String(describing: QTCloseAccountInfoViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Close Account"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Actions
    @IBAction func onProceedButtonClicked(_ sender: Any) {
        navigationController?.pushViewController(QTCloseAccountTypeViewController.controller, animated: true)
    }
    
    // MARK: - Functions
}
