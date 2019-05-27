//
//  QTBecomeTutorViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 5/27/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTBecomeTutorViewController: BaseRegistrationController {

    // MARK: - Properties
    var isRegistration = false
    
    static var controller: QTBecomeTutorViewController {
        return QTBecomeTutorViewController(nibName: String(describing: QTBecomeTutorViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back_arrow"), style: .plain, target: self, action: #selector(backAction))
    }
    
    // MARK: - Actions
    @IBAction func onStartTutoringButtonClicked(_ sender: Any) {
        navigationController?.pushViewController(TutorAddSubjectsVC(), animated: true)
    }
    
    @objc func backAction() {
        if isRegistration {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
