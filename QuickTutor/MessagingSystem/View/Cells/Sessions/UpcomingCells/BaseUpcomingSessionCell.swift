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
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "startSessionButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "cancelSessionButton"), for: .normal)
    }
    
    override func handleButton1() {
        cancelSession(id: session.id)
        delegate?.sessionCell(self, shouldReloadSessionWith: session.id)
    }
    
    override func handleButton2() {
        showConversationWithUID(session.partnerId())
    }
    
    override func handleButton3() {
        startSession()
//        let vc = SessionStartVC()
//        vc.sessionId = session.id
//        vc.partnerId = session.partnerId()
//        navigationController.pushViewController(vc, animated: true)
    }

    func startSession() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let value = ["startedBy": uid, "startType": "manual", "sessionType": session.type]
        Database.database().reference().child("sessionStarts").child(uid).child(session.id).setValue(value)
        Database.database().reference().child("sessionStarts").child(session.partnerId()).child(session.id).setValue(value)
    }
    
}
