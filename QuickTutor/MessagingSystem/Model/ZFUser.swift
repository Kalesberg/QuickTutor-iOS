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
        username = dictionary["username"] as? String
        profilePicUrl = dictionary["profilePicUrl"] as? String
        uid = dictionary["uid"] as? String
        type = dictionary["type"] as? String
        isOnline = dictionary["online"] as? Bool
    }
    
}
