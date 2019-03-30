//
//  LearnerPendingSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class LearnerPendingSessionCell: BasePendingSessionCell, MessageButtonDelegate, CancelSessionButtonDelegate {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton1.setImage(UIImage(named: "cancelSessionButton"), for: .normal)
        actionView.actionButton2.setImage(UIImage(named: "messageSessionButton")
, for: .normal)
        actionView.actionButton3.setImage(UIImage(named: "viewProfileButton"), for: .normal)
    }

    override func handleButton1() {
        cancelSession(id: session.id)
    }

    override func handleButton2() {
        showConversationWithUID(session.partnerId())
    }
    
    override func handleButton3() {
        super.handleButton3()
        FirebaseData.manager.fetchTutor(session.partnerId(), isQuery: false, { tutor in
            guard let tutor = tutor else { return }
            let controller = QTProfileViewController.controller
            controller.user = tutor
            controller.profileViewType = .tutor
            navigationController.pushViewController(controller, animated: true)
        })
    }
}
