//
//  QTCloseAccountTypeViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 4/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

enum QTCloseAccountType {
    case tutor
    case both
}

class QTCloseAccountTypeViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tutorAccountButton: QTCustomButton!
    @IBOutlet weak var bothAccountsButton: QTCustomButton!
    
    static var controller: QTCloseAccountTypeViewController {
        return QTCloseAccountTypeViewController(nibName: String(describing: QTCloseAccountTypeViewController.self), bundle: nil)
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Close Account"
    }

    // MARK: - Actions
    @IBAction func onTutorAccountButtonClicked(_ sender: Any) {
        goToCloseAccountReasonScreen(accountType: .tutor)
    }
    
    @IBAction func onBothAccountsButtonClicked(_ sender: Any) {
        goToCloseAccountReasonScreen(accountType: .both)
    }
    
    // MARK: - Functions
    func goToCloseAccountReasonScreen(accountType: QTCloseAccountType) {
        let controller = QTCloseAccountReasonViewController.controller
        controller.closeAccountType = accountType
        navigationController?.pushViewController(controller, animated: true)
    }
}
