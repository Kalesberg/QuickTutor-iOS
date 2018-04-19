//
//  TutorUpcomingSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorUpcomingSessionCell: BaseUpcomingSessionCell {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "cancelSessionButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "viewProfileButton"), for: .normal)
    }
    
    override func handleButton3() {
        let vc = BaseSessionStartVC()
        vc.sessionId = session.id
        vc.partnerId = session.partnerId()
        navigationController.pushViewController(vc, animated: true)
    }
}
