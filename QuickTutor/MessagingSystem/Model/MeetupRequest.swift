//
//  SessionRequest.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/6/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Foundation

var sessionCache = [String: SessionRequest]()

class SessionRequest {
    var subject: String?
    var date: Double?
    var startTime: Double?
    var endTime: Double?
    var price: Double?
    var choice: String?
    var status: String?
    var expiration: Double?
    var id: String?
    
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
        return dictionary
    }
    
    init(data: [String: Any]) {
        subject = data["subject"] as? String
        date = data["date"] as? Double
        startTime = data["startTime"] as? Double
        endTime = data["endTime"] as? Double
        price = data["price"] as? Double
        choice = data["choice"] as? String
        status = data["status"] as? String
        expiration = data["expiration"] as? Double
    }
    
    func formattedDate() -> String? {
        guard let date = self.date else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateFromTimeInterval = Date(timeIntervalSince1970: date)
        return dateFormatter.string(from: dateFromTimeInterval)
    }
    
    func formattedStartTime() -> String? {
        guard let startTime = self.startTime else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let dateFromTimeInterval = Date(timeIntervalSince1970: startTime)
        return dateFormatter.string(from: dateFromTimeInterval)
    }
    
}
