//
//  BaseUpcomingSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class BaseUpcomingSessionCell: BaseSessionCell, MessageButtonDelegate, CancelSessionButtonDelegate {
    
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "cancelSessionButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "startSessionButton"), for: .normal)
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
    }
    
    override func handleButton1() {
        showConversationWithUID(session.partnerId())
    }
    
    override func handleButton2() {
        startSession()
    }
    
    override func handleButton3() {
        cancelSession(id: session.id)
        delegate?.sessionCell(self, shouldReloadSessionWith: session.id)
    }

    func startSession() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let value = ["startedBy": uid, "startType": "manual", "sessionType": session.type]
        Database.database().reference().child("sessionStarts").child(uid).child(session.id).setValue(value)
        Database.database().reference().child("sessionStarts").child(session.partnerId()).child(session.id).setValue(value)
    }
    
}
