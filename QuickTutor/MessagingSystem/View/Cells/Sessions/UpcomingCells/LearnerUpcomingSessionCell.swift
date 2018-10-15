//
//  LearnerUpcomingSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class LearnerUpcomingSessionCell: BaseUpcomingSessionCell {
    
    override func startSession() {
        delegate?.sessionCell(self, shouldStart: session)
    }
}
