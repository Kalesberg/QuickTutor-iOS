//
//  User.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/13/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Foundation
import Firebase

class User: Decodable {
    
    var username: String!
    var profilePicUrl: URL!
    var uid: String!
    var type: String!
    var isOnline: Bool!
    
    var formattedName: String {
        get {
            let name = username.split(separator: " ")
            let formatted = "\(name[0]) \(String(name[1]).prefix(1))."
            return formatted
        }
    }
    
    func updateOnlineStatus(_ seconds: Double) {
        let differenceInSeconds = Date().timeIntervalSince1970 - seconds
        isOnline = differenceInSeconds <= 240
    }
    
    init(dictionary: [String: Any]) {
        username = (dictionary["username"] as? String)?.capitalized ?? ""
        let profilePicString = dictionary["profilePicUrl"] as? String ?? ""
        profilePicUrl = URL(string: profilePicString)
        uid = dictionary["uid"] as? String
        type = dictionary["type"] as? String ?? ""
        let onlineSecondsAgo = dictionary["online"] as? Double ?? 1000
        updateOnlineStatus(onlineSecondsAgo)
    }
}

class ZFTutor: User {
    var region: String?
    var subjects: [String]?
    var rating: Double?
    var hoursTaught: Int?
    var totalSessions: Int?
    var stripeAccountId: String?
    
    override init(dictionary: [String : Any]) {
        super.init(dictionary: dictionary)
        region = dictionary["rg"] as? String
        rating = dictionary["r"] as? Double
        hoursTaught = dictionary["hr"] as? Int
        totalSessions = dictionary["nos"] as? Int
        stripeAccountId = dictionary["act"] as? String
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
