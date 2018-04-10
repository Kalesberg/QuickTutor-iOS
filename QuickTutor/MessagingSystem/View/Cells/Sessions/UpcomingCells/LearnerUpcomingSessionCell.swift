//
//  LearnerUpcomingSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class LearnerUpcomingSessionCell: BaseUpcomingSessionCell, MessageButtonDelegate, CancelSessionButtonDelegate {
    
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "startSessionButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "cancelSessionButton"), for: .normal)
        
    }
    
    override func handleButton1() {
        cancelSession(id: session.id)
    }
    
    override func handleButton2() {
        showConversationWithUID(session.partnerId())
    }
    
}
