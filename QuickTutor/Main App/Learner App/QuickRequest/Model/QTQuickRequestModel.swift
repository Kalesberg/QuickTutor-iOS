//
//  QTQuickRequest.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/23/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTQuickRequestModel {

    var subject: String
    var date: Double
    var startTime: Double
    var endTime: Double
    var minPrice: Double
    var maxPrice: Double
    var expiration: Double?
    var id: String
    var senderId: String
    var duration: Int
    var type: QTSessionType
    var expired: Bool?
    
    // Use in local.
    var userName: String?
    var profileImageUrl: URL?
    var price: Double? // the price applied by tutor
    var paymentType: QTSessionPaymentType? // the payment type applied by tutor
    
    var dictionaryRepresentation: [String: Any] {
        var dictionary = [String: Any]()
        dictionary["subject"] = subject
        dictionary["date"] = date
        dictionary["startTime"] = startTime
        dictionary["endTime"] = endTime
        dictionary["minPrice"] = minPrice
        dictionary["maxPrice"] = maxPrice
        dictionary["expiration"] = expiration
        dictionary["senderId"] = senderId
        dictionary["type"] = type.rawValue
        dictionary["duration"] = duration
        dictionary["expired"] = expired
        dictionary["id"] = id
        return dictionary
    }
    
    init(data: [String: Any]) {
        
        subject = data["subject"] as? String ?? ""
        date = data["date"] as? Double ?? 0
        startTime = data["startTime"] as? Double ?? 0
        endTime = data["endTime"] as? Double ?? 0
        minPrice = data["minPrice"] as? Double ?? 0
        maxPrice = data["maxPrice"] as? Double ?? 0
        expiration = data["expiration"] as? Double
        senderId = data["senderId"] as? String ?? ""
        duration = data["duration"] as? Int ?? 0
        if let typeValue = data["type"] as? String, let type = QTSessionType(rawValue: typeValue) {
            self.type = type
        } else {
            self.type = .online
        }
        id = data["id"] as? String ?? ""
        if isExpired() {
            expired = true
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
    
    func isExpired() -> Bool {
        if let expired = expired, expired {
            return true
        }
        
        guard let expiration = expiration else { return false }
        let isExpired = expiration + 3600 < Date().timeIntervalSince1970
        return isExpired
    }
    
    func getDurationText() -> String {
        // If the duration is shorter than an hour, just display the duration as minutes
        if (duration / 3600 < 1) {
            return "\(duration / 60) Minutes Needed"
        } else {
            return String(format: "%.1f", duration / 3600)
        }
    }
}
