//
//  Session.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class Session {
    
    var tutorId: String
    var learnerId: String
    var id: String
    var startTime: Double
    var subject: String
    var date: Double
    var endTime: Double
    var price: Double
    var type: String
    var status: String
    
    init(dictionary: [String: Any], id: String) {
        tutorId = dictionary["tutorId"] as? String ?? ""
        learnerId = dictionary["learnerId"] as? String ?? ""
        startTime = dictionary["startTime"] as? Double ?? 0
        endTime = dictionary["endTime"] as? Double ?? 0
        date = dictionary["date"] as? Double ?? 0
        price = dictionary["price"] as? Double ?? 0
        type = dictionary["type"] as? String ?? ""
        status = dictionary["status"] as? String ?? ""
        subject = dictionary["subject"] as? String ?? ""
        self.id = id
     }
}
