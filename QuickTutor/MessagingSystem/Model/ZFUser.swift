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
    
    init(dictionary: [String: Any]) {
        username = dictionary["username"] as? String ?? ""
        profilePicUrl = dictionary["profilePicUrl"] as? String ?? ""
        uid = dictionary["uid"] as? String
        type = dictionary["type"] as? String ?? ""
        isOnline = dictionary["online"] as? Bool ?? false
    }
    
}

class ZFTutor: User {
    var region: String?
    var subjects: [String]?
    
    override init(dictionary: [String : Any]) {
        super.init(dictionary: dictionary)
        region = dictionary["rg"] as? String
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
