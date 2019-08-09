//
//  ConversationMetaData.swift
//  QuickTutor
//
//  Created by Zach Fuller on 9/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

class ConversationMetaData {
    var uid: String?
    var lastMessageId: String?
    var lastMessageContent: String?
    var lastMessageSenderId: String?
    var isConnected = false
    var lastUpdated: Double?
    var hasRead: Bool?
    var memberIds: [String] = []
    var partner: User?
    var message: UserMessage?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        lastMessageId = dictionary["lastMessageId"] as? String
        lastMessageContent = dictionary["lastMessageContent"] as? String
        lastMessageSenderId = dictionary["lastMessageSenderId"] as? String
        lastUpdated = dictionary["lastUpdatedAt"] as? Double
        isConnected = dictionary["isConnected"] as? Bool ?? false
        memberIds = dictionary["memberIds"] as? [String] ?? []
        hasRead = checkHasRead(dictionary: dictionary)
    }
    
    func checkHasRead(dictionary: [String: Any]) -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        guard let readByIds = dictionary["readBy"] as? [String: Any] else { return true }
        return readByIds[uid] != nil
    }
    
    func chatPartnerId() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return memberIds[0] == uid ? memberIds[1] : memberIds[0]
    }
    
    func updateMetadata(newData: ConversationMetaData) {
        lastMessageId = newData.lastMessageId
        lastMessageContent = newData.lastMessageContent
        lastMessageSenderId = newData.lastMessageContent
        lastUpdated = newData.lastUpdated
        hasRead = newData.hasRead
    }
}
