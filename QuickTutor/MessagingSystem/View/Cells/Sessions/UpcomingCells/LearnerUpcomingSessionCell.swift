//
//  LearnerUpcomingSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class LearnerUpcomingSessionCell: BaseUpcomingSessionCell {
    
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "startSessionButton"), for: .normal)
    }
    
    override func handleButton3() {
        let vc = SessionStartVC()
        vc.sessionId = session.id
        vc.partnerId = session.partnerId()
        navigationController.pushViewController(vc, animated: true)
    }
}
