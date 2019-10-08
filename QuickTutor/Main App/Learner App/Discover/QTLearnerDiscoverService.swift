//
//  QTLearnerDiscoverService.swift
//  QuickTutor
//
//  Created by Michael Burkard on 10/3/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

enum QTLearnerDiscoverTutorSectionType {
    case category, subcategory
}

class QTLearnerDiscoverTutorSectionInterface {
    var type: QTLearnerDiscoverTutorSectionType!
    var key: String!
    var tutors: [AWTutor]?
    var totalTutorIds: [String]?
        
    init(type: QTLearnerDiscoverTutorSectionType = .category, key: String, tutors: [AWTutor]?, totalTutorIds: [String]?) {
        self.type = type
        self.key = key
        self.tutors = tutors
        self.totalTutorIds = totalTutorIds
    }
}

class QTLearnerDiscoverService {
    static let shared = QTLearnerDiscoverService()
    
    let MAX_API_LIMIT = 6
    
    var category: Category?
    var subcategory: String?
    var isFirstTop = true
    var isRisingTalent = false
    
    var topTutorsLimit: Int?
    var risingTalentLimit = 50
    
    var sectionTutors: [QTLearnerDiscoverTutorSectionInterface] = []
    
}
