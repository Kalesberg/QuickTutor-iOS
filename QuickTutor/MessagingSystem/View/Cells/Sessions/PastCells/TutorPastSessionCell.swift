//
//  TutorPastSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorPastSessionCell: BasePastSessionCell, MessageButtonDelegate, RequestSessionButtonDelegate {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsDoubleButton()
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "messageButtonWhiteTutor"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "viewProfileIconWhiteTutor"), for: .normal)
    }
    
    
    override func handleButton1() {
        showConversationWithUID(session.partnerId())
    }
    override func handleButton2() {
        FirebaseData.manager.fetchLearner(session.partnerId()) { (learner) in
            guard let learner = learner else { return }
            let vc = LearnerMyProfile()
            vc.learner = learner
            vc.contentView.rightButton.isHidden = true
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
}
