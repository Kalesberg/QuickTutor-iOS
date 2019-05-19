//
//  CrossoverPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import Foundation
import UIKit

class BecomeTutorVC: BaseRegistrationController {
    
    var isRegistration = false
    
    let contentView: BecomeTutorVCView = {
        let view = BecomeTutorVCView()
        return view
    }()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        setupContentView()
        progressView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back_arrow"), style: .plain, target: self, action: #selector(backAction))
    }
    
    func setupTargets() {
        contentView.nextButton.addTarget(self, action: #selector(handleNext(_:)), for: .touchUpInside)
    }

    func setupContentView() {
        contentView.layoutIfNeeded()
        contentView.scrollView.contentSize = CGSize(width: contentView.scrollView.frame.width, height: contentView.contentLabel.frame.height)
    }

    @objc func handleNext(_ sender: UIButton) {
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
