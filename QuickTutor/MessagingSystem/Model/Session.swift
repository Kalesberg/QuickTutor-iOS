//
//  Session.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import Foundation

class Session: Codable {
    var senderId: String
    var receiverId: String
    var id: String
    var startTime: Double
    var subject: String
    var date: Double
    var endTime: Double
    var price: Double
    var cost: Double
    var type: String
    var paymentType: String
    var duration: Int
    var status: String
    var runTime: Int
    var rating: Double

    init(dictionary: [String: Any], id: String) {
        self.id = id
        senderId = dictionary["senderId"] as? String ?? ""
        receiverId = dictionary["receiverId"] as? String ?? ""
        startTime = dictionary["startTime"] as? Double ?? 0
        endTime = dictionary["endTime"] as? Double ?? 0
        date = dictionary["date"] as? Double ?? 0
        price = dictionary["price"] as? Double ?? 0
        type = dictionary["type"] as? String ?? ""
        status = dictionary["status"] as? String ?? ""
        subject = dictionary["subject"] as? String ?? ""
        cost = dictionary["cost"] as? Double ?? 0
        runTime = dictionary["runTime"] as? Int ?? 0
        paymentType = dictionary["paymentType"] as? String ?? QTSessionPaymentType.hour.rawValue
        duration = dictionary["duration"] as? Int ?? 1200
        rating = dictionary["rating"] as? Double ?? 0
    }
    
    init(_ session: Session) {
        senderId = session.senderId
        receiverId = session.receiverId
        startTime = session.startTime
        endTime = session.endTime
        date = session.date
        price = session.price
        type = session.type
        status = session.status
        subject = session.subject
        cost = session.cost
        runTime = session.runTime
        paymentType = session.paymentType
        duration = session.duration
        id = session.id
        rating = session.rating
    }
    
    func lengthInMinutes() -> Double {
        let lengthInSeconds = endTime - startTime
        print(lengthInSeconds)
        return lengthInSeconds / 60
    }

    func partnerId() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return receiverId == uid ? senderId : receiverId
    }

    func getFormattedInfoLabelString() -> String {
        let lengthInSeconds = endTime - startTime
        let lengthInMinutes = Int(lengthInSeconds / 60)
        let finalString = "Length: \(lengthInMinutes) min, $\(Int(price)) / hr"
        return finalString
    }
    
    func isExpired() -> Bool {
        guard "accepted" == status || "pending" == status else { return false }
        return startTime + 3600 < Date().timeIntervalSince1970
    }
    
    var isPast: Bool {
        return startTime < Date().timeIntervalSince1970 && status == "completed"
    }

    func isNeededToStartNow() -> Bool {
        guard status == QTSessionStatusType.accepted.rawValue else { return false}
        return startTime > Date().timeIntervalSince1970 && startTime + 3600 <= Date().timeIntervalSince1970
    }
    
    func cancel() {}
    
    var sessionCost: Double {
        if .learner == AccountService.shared.currentUserType {
            return (cost + 0.3) / 0.971
        }
        
        return cost
    }
    
    var sessionPrice: Double {
        if .learner == AccountService.shared.currentUserType {
            return (price + 0.3) / 0.971
        }
        
        return price
    }
}
