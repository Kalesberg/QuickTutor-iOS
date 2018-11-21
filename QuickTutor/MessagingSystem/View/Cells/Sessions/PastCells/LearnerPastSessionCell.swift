//
//  LearnerPastSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class LearnerPastSessionCell: BasePastSessionCell, MessageButtonDelegate, RequestSessionButtonDelegate {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "requestSessionIcon"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "viewProfileButton"), for: .normal)
    }

    override func handleButton1() {
        super.handleButton1()
        requestSession(session.partnerId())
    }

    override func handleButton2() {
        super.handleButton2()
        showConversationWithUID(session.partnerId())
    }

    override func handleButton3() {
        super.handleButton3()
        FirebaseData.manager.fetchTutor(session.partnerId(), isQuery: false, { tutor in
            guard let tutor = tutor else { return }
            let vc = TutorMyProfileVC()
            vc.tutor = tutor
            vc.isViewing = true
            vc.navigationItem.title = tutor.username
            navigationController.pushViewController(vc, animated: true)
        })
    }
}
