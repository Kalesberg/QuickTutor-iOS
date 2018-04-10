//
//  LearnerPastSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class LearnerPastSessionCell: BasePastSessionCell, MessageButtonDelegate {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "viewProfileButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "requestSessionButton"), for: .normal)
    }
    
    override func handleButton2() {
        print(session.receiverId)
        print(session.senderId)
    }
}
