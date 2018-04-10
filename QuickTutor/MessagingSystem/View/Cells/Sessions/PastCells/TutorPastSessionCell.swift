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
        actionView.setupAsTripleButton()
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "requestSessionButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "viewProfileButton"), for: .normal)
    }
    
    override func handleButton1() {
        requestSession(session.partnerId())
    }
    
    override func handleButton2() {
        showConversationWithUID(session.partnerId())
    }
    
    override func handleButton3() {
        
    }
}
