//
//  Conversation.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

struct Conversation {
    
    var uid: String!
    var members: (currentUser: User, chatPartner: User)!
    var memberIds: [String]!
    var lastMessageId: String!
    var lastReadMessageIds: (currentUser: String, chatPartner: String)!
    var lastUpdated: Double!
    var lastMessage: UserMessage?
    var chatPartnerProfilePicUrl: String!
    var chatPartnerUsername: String!
    
    init(dictionary: [String: Any]) {
        
    }
}
