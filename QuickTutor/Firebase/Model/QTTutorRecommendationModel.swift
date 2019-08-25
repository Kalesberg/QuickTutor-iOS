//
//  QTTutorRecommendationModel.swift
//  QuickTutor
//
//  Created by Michael Burkard on 8/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import ObjectMapper

class QTTutorRecommendationModel: Mappable {
    var learnerId: String?
    var learnerName: String?
    var learnerAvatarUrl: String?
    var recommendationText: String?
    var createdAt: Date?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        learnerId                   <- map["learnerId"]
        learnerName                 <- map["learnerName"]
        learnerAvatarUrl            <- map["learnerAvatarUrl"]
        recommendationText          <- map["recommendationText"]
        createdAt                   <- (map["createdAt"], QTTutorRecommendationModel.dateTransform)
    }
    
    static let dateTransform = TransformOf<Date, Double>(fromJSON: { value -> Date? in
        guard let value = value else { return nil }
        return Date(timeIntervalSince1970: value)
    }, toJSON: { value -> Double? in
        return value?.timeIntervalSince1970
    })
}
