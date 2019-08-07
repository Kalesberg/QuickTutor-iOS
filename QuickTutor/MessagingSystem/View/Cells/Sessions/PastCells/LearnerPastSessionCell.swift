//
//  LearnerPastSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit



class LearnerPastSessionCell: BasePastSessionCell, MessageButtonDelegate, RequestSessionButtonDelegate, ViewProfileButtonDelegate {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton1.setImage(UIImage(named: "requestSessionButtonCircle"), for: .normal)
        actionView.actionButton2.setImage(UIImage(named: "messageSessionButton"), for: .normal)
        actionView.actionButton3.setImage(UIImage(named: "viewProfileButton"), for: .normal)
    }

    override func handleButton1() {
        super.handleButton1()
        guard let partnerId = session.partnerId() else { return }
        requestSession(partnerId)
    }

    override func handleButton2() {
        super.handleButton2()
        guard let partnerId = session.partnerId() else { return }
        showConversationWithUID(partnerId)
    }

    override func handleButton3() {
        super.handleButton3()
        guard let partnerId = session.partnerId() else { return }
        viewProfileWithUID(partnerId)
    }
}
