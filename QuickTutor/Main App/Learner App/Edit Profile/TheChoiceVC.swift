//
//  TheChoice.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseAuth
import UIKit

class TheChoiceVC: UIViewController {
    
    let contentView: TheChoiceVCView = {
        let view = TheChoiceVCView()
        return view
    }()

    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        removeNavBarBackButton()
    }
    
    func setupTargets() {
        contentView.startButton.addTarget(self, action: #selector(handleStartButton), for: .touchUpInside)
    }
    
    func removeNavBarBackButton() {
        navigationItem.setHidesBackButton(true, animated:true);
    }
    
    @objc func handleStartButton() {
        if contentView.userType == .learner {
            displayLoadingOverlay()
            FirebaseData.manager.fetchLearner(Registration.uid) { learner in
                self.dismissOverlay()
                if let learner = learner {
                    CurrentUser.shared.learner = learner
                    AccountService.shared.loadUser(isFacebookLogin: nil != Registration.facebookInfo)
                    AccountService.shared.currentUserType = .learner
                    
                    RootControllerManager.shared.configureRootViewController(controller: LearnerMainPageVC())
                    let endIndex = self.navigationController?.viewControllers.endIndex
                    self.navigationController?.viewControllers.removeFirst(endIndex! - 1)
                } else {
                    self.navigationController?.pushViewController(GetStartedViewController(), animated: true)
                }
            }
        } else {
            displayLoadingOverlay()
            FirebaseData.manager.fetchLearner(Registration.uid) { learner in
                self.dismissOverlay()
                if let learner = learner {
                    CurrentUser.shared.learner = learner
                    let vc = QTBecomeTutorViewController.controller
                    vc.isRegistration = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.navigationController?.pushViewController(GetStartedViewController(), animated: true)
                }
            }
        }
    }
}
