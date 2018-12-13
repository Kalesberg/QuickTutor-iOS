//
//  TutorCardVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorCardVC: UIViewController {
    
    let contentView = TutorCardView()
    var tutor: AWTutor?
    var subject: String?
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        setupNavBar()
        contentView.tutor = tutor
        contentView.headerView.subjectLabel.text = subject
        contentView.parentViewController = self
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"newBackButton"), style: .plain, target: self, action: #selector(onBack))
        navigationController?.view.backgroundColor = Colors.darkBackground
    }
    
    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }
}
