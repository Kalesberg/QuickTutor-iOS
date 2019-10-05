//
//  QTLearnerDiscoverService.swift
//  QuickTutor
//
//  Created by Michael Burkard on 10/3/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerDiscoverService {
    static let shared = QTLearnerDiscoverService()
    
    var category: Category?
    var subcategory: String?
    var isRisingTalent = false
    
    var topTutorsLimit: Int?
    var risingTalentLimit = 50
}
