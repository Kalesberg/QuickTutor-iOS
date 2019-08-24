//
//  QTQuickRequestDoneViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/23/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTQuickRequestDoneViewController: UIViewController {

    // MARK: - Properties
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Actions
    @IBAction func OnDoneButtonClicked(_ sender: Any) {
        self.navigationController?.popBackToMain()
    }
    
    
    // MARK: - Functions
}
