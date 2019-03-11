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
    }
    
    func setupTargets() {
        contentView.startButton.addTarget(self, action: #selector(handleStartButton), for: .touchUpInside)
    }
    
    @objc func handleStartButton() {
        if contentView.userType == .learner {
            FirebaseData.manager.fetchLearner(Registration.uid) { learner in
                if let learner = learner {
                    CurrentUser.shared.learner = learner
                    AccountService.shared.currentUserType = .learner
                    RootControllerManager.shared.setupLearnerTabBar(controller: LearnerMainPageVC())
                    let endIndex = self.navigationController?.viewControllers.endIndex
                    self.navigationController?.viewControllers.removeFirst(endIndex! - 1)
                } else {
                    try! Auth.auth().signOut()
                    self.navigationController?.pushViewController(SignInVC(), animated: true)
                }
            }
        } else {
            FirebaseData.manager.fetchLearner(Registration.uid) { learner in
                if let learner = learner {
                    self.dismissOverlay()
                    CurrentUser.shared.learner = learner
                    AccountService.shared.currentUserType = .tRegistration
                    self.navigationController?.pushViewController(BecomeTutorVC(), animated: true)
                } else {
                    self.dismissOverlay()
                    try! Auth.auth().signOut()
                    self.navigationController?.pushViewController(SignInVC(), animated: true)
                }
            }
        }
    }
}
