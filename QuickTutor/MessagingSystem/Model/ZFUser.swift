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
    var profilePicUrl: String!
    var uid: String!
    var type: String!
    var isOnline: Bool!
    
    var formattedName: String {
        get {
            let name = username.split(separator: " ")
            let formatted = "\(name[0]) \(String(name[1]).prefix(1))"
            return formatted
        }
    }
    
    init(dictionary: [String: Any]) {
        username = (dictionary["username"] as? String)?.capitalized ?? ""
        profilePicUrl = dictionary["profilePicUrl"] as? String ?? ""
        uid = dictionary["uid"] as? String
        type = dictionary["type"] as? String ?? ""
        isOnline = dictionary["online"] as? Bool ?? false
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
