//
//  TutorPastSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorPastSessionCell: BasePastSessionCell, MessageButtonDelegate, RequestSessionButtonDelegate, ViewProfileButtonDelegate {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsDoubleButton()
        actionView.actionButton1.setImage(UIImage(named: "messageSessionButton"), for: .normal)
        actionView.actionButton2.setImage(UIImage(named: "viewProfileButton"), for: .normal)
    }

    override func handleButton1() {
        showConversationWithUID(session.partnerId())
    }

    override func handleButton2() {
        viewProfileWithUID(session.partnerId())
    }
}
