//
//  ConversationMetaData.swift
//  QuickTutor
//
//  Created by Zach Fuller on 9/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

struct ConversationMetaData {
    var lastMessageId: String?
    var lastMessageSenderId: String?
    var isConnected = false
    var lastUpdated: Double?
    var hasRead: Bool?
    var memberIds = [String]()
    
    init(dictionary: [String: Any]) {
        lastMessageId = dictionary["lastMessageId"] as? String
        lastMessageSenderId = dictionary["lastMessageSenderId"] as? String
        lastUpdated = dictionary["lastUpdatedAt"] as? Double
        isConnected = dictionary["isConnected"] as? Bool ?? false
        memberIds = dictionary["memberIds"] as? [String] ?? [String]()
        hasRead = checkHasRead(dictionary: dictionary)
    }
    
    func checkHasRead(dictionary: [String: Any]) -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
        guard let readByIds = dictionary["readBy"] as? [String: Any] else { return true }
        return readByIds[uid] != nil
    }
    
    func chatPartnerId() -> String {
        guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
        return memberIds[0] == uid ? memberIds[1] : memberIds[0]
    }
}
