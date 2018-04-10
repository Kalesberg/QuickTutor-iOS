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
        actionView.setupAsDoubleButton()
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "cancelSessionButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
    }
    
    override func handleButton1() {
        cancelSession()
    }
    
    override func handleButton2() {
        showConversationWithUID(session.partnerId())
    }
    
}
