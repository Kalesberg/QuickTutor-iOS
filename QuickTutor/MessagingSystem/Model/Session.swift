//
//  Session.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

class Session: Codable {
    
    var senderId: String
    var receiverId: String
    var id: String
    var startTime: Double
    var subject: String
    var date: Double
    var endTime: Double
    var price: Double
    var type: String
    var status: String

    init(dictionary: [String: Any], id: String) {
        senderId = dictionary["senderId"] as? String ?? ""
        receiverId = dictionary["receiverId"] as? String ?? ""
        startTime = dictionary["startTime"] as? Double ?? 0
        endTime = dictionary["endTime"] as? Double ?? 0
        date = dictionary["date"] as? Double ?? 0
        price = dictionary["price"] as? Double ?? 0
        type = dictionary["type"] as? String ?? ""
        status = dictionary["status"] as? String ?? ""
        subject = dictionary["subject"] as? String ?? ""
        self.id = id
     }
    
    func partnerId() -> String {
        guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
        return receiverId == uid ? senderId : receiverId
    }
}
