//
//  ConversationManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class MessageBuilder {
    //    func loadFromData(_ data: [String: Any]) -> Messageable {
    //        if let connectionRequestId = data["connectionRequestId"] as? String {
    //
    //        }
    //    }
}

class ConversationManager {
    
    var delegate: ConversationManagerDelegate?
    var memberIds: [String]?
    var readByIds: [String]?
    var messages: [BaseMessage]?
    var chatPartnerId: String?
    
    func loadMessages() {
        messages = [BaseMessage]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("conversations").child(uid).child(userTypeString).child(chatPartnerId ?? "").observe(.childAdded) { snapshot in
            let messageId = snapshot.key
            DataService.shared.getMessageById(messageId, completion: { message in
                
                self.messages?.append(message)
                print("Conversation messages:", self.messages)
                print("Message:", message.data)
                self.delegate?.conversationManager(self, didLoad: self.messages!)
            })
        }
    }
    
    
    
}

struct Conversation {
    
}

protocol ConversationManagerDelegate {
    func conversationManager(_ conversationManager: ConversationManager, didReceive message: BaseMessage)
    func conversationManager(_ conversationManager: ConversationManager, didLoad messages: [BaseMessage])
    func conversationManager(_ conversationManager: ConversationManager, didUpdateReadReceipt hasRead: Bool)
}

class ConversationManagerFacade: ConversationManagerDelegate {
    func conversationManager(_ conversationManager: ConversationManager, didReceive message: BaseMessage) {
        
    }
    
    func conversationManager(_ conversationManager: ConversationManager, didLoad messages: [BaseMessage]) {
        print("Here here here")
    }
    
    func conversationManager(_ conversationManager: ConversationManager, didUpdateReadReceipt hasRead: Bool) {
        
    }
}
