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
    var status: String
    var runTime: Int

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
        cost = dictionary["cost"] as? Double ?? 0
        runTime = dictionary["runTime"] as? Int ?? 0
        self.id = id
    }

    func lengthInMinutes() -> Double {
        let lengthInSeconds = endTime - startTime
        print(lengthInSeconds)
        return lengthInSeconds / 60
    }

    func partnerId() -> String {
        guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
        return receiverId == uid ? senderId : receiverId
    }

    func getFormattedInfoLabelString() -> String {
        let lengthInSeconds = endTime - startTime
        let lengthInMinutes = Int(lengthInSeconds / 60)
        let finalString = "Length: \(lengthInMinutes) min, $\(Int(price)) / hr"
        return finalString
    }

    func cancel() {}
}
