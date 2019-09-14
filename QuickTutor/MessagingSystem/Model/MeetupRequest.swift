//
//  SessionRequest.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/6/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase
import Foundation

var sessionCache = [String: SessionRequest]()

enum QTSessionPaymentType: String {
    case session, hour
}

class SessionRequest {
    var subject: String
    var date: Double
    var startTime: Double
    var endTime: Double
    var price: Double
    var choice: String?
    var status: String?
    var expiration: Double?
    var id: String?
    var senderId: String
    var receiverId: String
    var paymentType: QTSessionPaymentType = .hour
    var duration: Int
    var type: String
    var receiverAccountType: String?
    var quickRequestId: String?

    var dictionaryRepresentation: [String: Any] {
        var dictionary = [String: Any]()
        dictionary["subject"] = subject
        dictionary["date"] = date
        dictionary["startTime"] = startTime
        dictionary["endTime"] = endTime
        dictionary["price"] = price
        dictionary["choice"] = choice
        dictionary["status"] = status
        dictionary["expiration"] = expiration
        dictionary["senderId"] = senderId
        dictionary["receiverId"] = receiverId
        dictionary["type"] = type
        dictionary["paymentType"] = paymentType.rawValue
        dictionary["duration"] = duration
        dictionary["receiverAccountType"] = receiverAccountType
        dictionary["quickRequestId"] = quickRequestId
        return dictionary
    }

    init(data: [String: Any]) {
        subject = data["subject"] as? String ?? ""
        date = data["date"] as? Double ?? 0
        startTime = data["startTime"] as? Double ?? 0
        endTime = data["endTime"] as? Double ?? 0
        price = data["price"] as? Double ?? 0
        choice = data["choice"] as? String
        status = data["status"] as? String
        expiration = data["expiration"] as? Double
        senderId = data["senderId"] as? String ?? ""
        receiverId = data["receiverId"] as? String ?? ""
        if let paymentType = data["paymentType"] as? String {
            self.paymentType = QTSessionPaymentType(rawValue: paymentType) ?? .hour
        } else {
            paymentType = .hour
        }
        duration = data["duration"] as? Int ?? 0
        type = data["type"] as? String ?? ""
        receiverAccountType = data["receiverAccountType"] as? String
        quickRequestId = data["quickRequestId"] as? String
        if isExpired() {
            status = "expired"
        }
    }

    func formattedDate() -> String? {
        guard self.date != 0 else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE MMM dd"
        let dateFromTimeInterval = Date(timeIntervalSince1970: date)
        return dateFormatter.string(from: dateFromTimeInterval)
    }

    func formattedStartTime() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let dateFromTimeInterval = Date(timeIntervalSince1970: startTime)
        return dateFormatter.string(from: dateFromTimeInterval)
    }

    func formattedEndTime() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let dateFromTimeInterval = Date(timeIntervalSince1970: endTime)
        return dateFormatter.string(from: dateFromTimeInterval)
    }

    func partnerId() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return receiverId == uid ? senderId : receiverId
    }
    
    func isExpired() -> Bool {
        guard let expiration = expiration, status == "pending" else { return false }
        let isExpired = expiration + 3600 < Date().timeIntervalSince1970
        return isExpired
    }
}
