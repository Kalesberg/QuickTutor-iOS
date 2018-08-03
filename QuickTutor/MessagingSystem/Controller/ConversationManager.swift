//
//  ConversationManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class ConnectionManager {
    func createConnectionWith(uid: String) {
        
    }
    
    func removeConnectionWith(uid: String) {
        
    }
    
    func getAllConnectedIds() {
        
    }
    
}

class ReadReceiptLabelManager {
    
}

class MessageBuilder {
    //    func loadFromData(_ data: [String: Any]) -> Messageable {
    //        if let connectionRequestId = data["connectionRequestId"] as? String {
    //
    //        }
    //    }
}

class ConversationManager {
    
    var delegate: ConversationManagerDelegate?
    var metaData: ConversationMetaData?
    var memberIds: [String]?
    var readByIds: [String]?
    var messages: [BaseMessage]?
    var chatPartnerId: String?
    var chatPartner: User?
    var canSendMessage = true
    var isConnected = false
    var uid: String!
    
    func loadPreviousMessagesByTimeStamp(limit: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("conversations").child(uid).child(userTypeString).child(chatPartnerId ?? "").observeSingleEvent(of: .value) { (snapshot) in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
            var fetchedMessageCount = 0
            for child in children {
                DataService.shared.getMessageById(child.key, completion: { (message) in
                    self.messages?.append(message)
                    fetchedMessageCount += 1
                })
            }
        }
        
    }
    
    func listenForNewMessages() {
        messages = [BaseMessage]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("conversations").child(uid).child(userTypeString).child(chatPartnerId ?? "").observe(.childAdded) { snapshot in
            let messageId = snapshot.key
            DataService.shared.getMessageById(messageId, completion: { message in
                self.messages?.append(message)
                self.delegate?.conversationManager(self, didReceive: message)
            })
        }
    }
    
    
    func listenForReadReceipts() {
        guard let uid = Auth.auth().currentUser?.uid, let id = chatPartnerId else { return }
        Database.database().reference().child("readReceipts").child(uid).child(id).observe(.value) { snapshot in
            guard let read = snapshot.value as? Bool else { return }
            self.delegate?.conversationManager(self, didUpdateReadReceipt: read)
        }
    }
    
    func listenForConnections() {
        guard let id = chatPartnerId else { return }
        Database.database().reference().child("connections").child(uid).child(id).observe(.value) { (snapshot) in
            guard let value = snapshot.value as? Bool else {
                self.delegate?.conversationManager(self, didUpdateConnection: false)
                return
            }
            self.isConnected = value
            self.delegate?.conversationManager(self, didUpdateConnection: value)
        }
    }
    
//    init() {
//        guard let id = Auth.auth().currentUser?.uid else { fatalError() }
//        uid = id
//        listenForNewMessages()
//        listenForReadReceipts()
//        listenForConnections()
//    }
    
    func setup() {
        guard let id = Auth.auth().currentUser?.uid else { fatalError() }
        uid = id
        listenForNewMessages()
        listenForReadReceipts()
        listenForConnections()
    }
}

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

struct ConversationMetaData {
    var lastMessageId: String?
    var lastMessageSenderId: String?
    var isConnected = false
    var lastUpdated: Double?
    
    init(dictionary: [String: Any]) {
        lastMessageId = dictionary["lastMessageId"] as? String
        lastMessageSenderId = dictionary["lastMessageSenderId"] as? String
        lastUpdated = dictionary["lastUpdatedAt"] as? Double
        isConnected = dictionary["isConnected"] as? Bool ?? false
    }
}


protocol ConversationManagerDelegate {
    func conversationManager(_ conversationManager: ConversationManager, didReceive message: UserMessage)
    func conversationManager(_ conversationManager: ConversationManager, didLoad messages: [BaseMessage])
    func conversationManager(_ conversationManager: ConversationManager, didUpdateReadReceipt hasRead: Bool)
    func conversationManager(_ convesationManager: ConversationManager, didUpdateConnection connected: Bool)
}

class ConversationManagerFacade: ConversationManagerDelegate {
    func conversationManager(_ conversationManager: ConversationManager, didReceive message: UserMessage) {
        
    }
    
    func conversationManager(_ conversationManager: ConversationManager, didLoad messages: [BaseMessage]) {
        print("Here here here")
    }
    
    func conversationManager(_ conversationManager: ConversationManager, didUpdateReadReceipt hasRead: Bool) {
        
    }
    
    func conversationManager(_ convesationManager: ConversationManager, didUpdateConnection connected: Bool) {
        
    }
}
