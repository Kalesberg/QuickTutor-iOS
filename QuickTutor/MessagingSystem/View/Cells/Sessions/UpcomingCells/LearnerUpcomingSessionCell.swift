//
//  LearnerUpcomingSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class LearnerUpcomingSessionCell: BaseUpcomingSessionCell {
    override func handleButton2() {
        let vc = BaseSessionStartVC()
        vc.sessionId = session.id
        vc.partnerId = session.partnerId()
        navigationController.pushViewController(vc, animated: true)
    }
}
