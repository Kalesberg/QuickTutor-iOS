//
//  ConversationManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

protocol ConversationManagerDelegate: class {
    func conversationManager(_ conversationManager: ConversationManager, didReceive message: UserMessage)
    func conversationManager(_ conversationManager: ConversationManager, didLoad messages: [BaseMessage])
    func conversationManager(_ conversationManager: ConversationManager, didUpdate readByIds: [String])
    func conversationManager(_ convesationManager: ConversationManager, didUpdateConnection connected: Bool)
    func conversationManager(_ conversationManager: ConversationManager, didLoadAll messages: [BaseMessage])
}



class ConversationManager {
    
    weak var delegate: ConversationManagerDelegate?
    var metaData: ConversationMetaData?
    var memberIds: [String]?
    var readByIds: [String]?
    var messages = [BaseMessage]()
    var chatPartnerId: String?
    var chatPartner: User?
    var isConnected = false
    var uid: String!
    var earliestLoadedMessageId: String?
    var isFinishedPaginating = true
    var loadedAllMessages = false
    var isInitialLoad = true
    var lastSendMessageIndex = -1

    var readReceiptManager: ReadReceiptManager?

    func loadPreviousMessagesByTimeStamp(limit: Int, completion: @escaping ([BaseMessage]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard !loadedAllMessages else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue

        let ref = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(chatPartnerId ?? "")
        var query = ref.queryOrderedByKey()
        if let lastMessageId = earliestLoadedMessageId {
            query = query.queryEnding(atValue: lastMessageId)
            print(lastMessageId)
        }
        query = query.queryLimited(toLast: UInt(limit))

        var previousMessages = [BaseMessage]()
        query.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                self.delegate?.conversationManager(self, didLoadAll: self.messages)
                completion([BaseMessage]())
                return
            }
            var fetchedMessageCount = 0
            if children.count == 0 {
                completion([UserMessage]())
            }
            if children.count < limit {
                self.loadedAllMessages = true
            }
            for child in children {
                DataService.shared.getMessageById(child.key, completion: { message in
                    
                    
                    if let lastMessage = previousMessages.last as? UserMessage, let newMessage = message as? UserMessage,  lastMessage.timeStamp.doubleValue - newMessage.timeStamp.doubleValue < -3600 {
                        print("Messages are an hour apart")
                        let timestampDate = Date(timeIntervalSince1970: newMessage.timeStamp.doubleValue)
                        let text = timestampDate.formatRelativeStringForTimeSeparator()
                        let systemTimeMessage = MessageBreakTimestamp(attributedText: text)
                        systemTimeMessage.timestamp = newMessage.timeStamp
                        previousMessages.append(systemTimeMessage)
                    }
                    
                    previousMessages.append(message)

                    fetchedMessageCount += 1
                    if fetchedMessageCount == children.count {
                        if fetchedMessageCount < limit {
                            self.delegate?.conversationManager(self, didLoadAll: self.messages)
                        }
                        if !self.isInitialLoad {
                            previousMessages.removeLast()
                            if message.senderId == uid {
                                self.lastSendMessageIndex = previousMessages.count - 1
                            }
                        }
                        self.isInitialLoad = false
                        self.messages.insert(contentsOf: previousMessages, at: 0)
                        self.earliestLoadedMessageId = self.messages.first?.uid
                        self.delegate?.conversationManager(self, didLoad: previousMessages)
                        completion(previousMessages)
                    }
                })
            }
        }
    }

    func listenForNewMessages() {
        let query = getConversationQueryRef()
        query.observe(.childAdded) { snapshot in
            let messageId = snapshot.key
            guard !self.messages.contains(where: {$0.uid == messageId}) else { return }
            DataService.shared.getMessageById(messageId, completion: { message in
                if message.senderId == self.uid {
                    self.lastSendMessageIndex = self.messages.count - 1
                    self.readReceiptManager?.invalidateReadReceipt()
                }
                self.earliestLoadedMessageId = self.messages.first?.uid
                self.delegate?.conversationManager(self, didReceive: message)
            })
        }
    }

    private func getConversationQueryRef() -> DatabaseQuery {
        let uid = (Auth.auth().currentUser?.uid)!
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let ref = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(chatPartnerId ?? "")
        var query = ref.queryOrderedByKey()
        if let lastMessageId = metaData?.lastMessageId {
            query = query.queryStarting(atValue: lastMessageId)
        }
        query = query.queryLimited(toLast: 50)
        return query
    }

    func listenForConnections() {
        guard let id = chatPartnerId else { return }
        let currentUserType = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("connections").child(uid).child(currentUserType).child(id).observe(.value) { snapshot in
            guard let value = snapshot.value as? Bool else {
                self.delegate?.conversationManager(self, didUpdateConnection: false)
                return
            }
            self.isConnected = value
            self.delegate?.conversationManager(self, didUpdateConnection: value)
        }
    }

    func getStatusMessageIndex() -> Int? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        guard messages.count != 0 else { return nil }

        var location = -1
        var index = 0
        for message in messages {
            location += 1
            guard let userMessage = message as? UserMessage else { continue }
            guard !(message is MessageBreakTimestamp) else { continue }
            if userMessage.senderId == uid {
                index = location + 1
            }
        }
        if index == 0 {
            return nil
        }
        return index
    }
    
    func setup() {
        guard let id = Auth.auth().currentUser?.uid else { fatalError() }
        uid = id
        loadPreviousMessagesByTimeStamp(limit: 50) { (messages) in
            self.listenForNewMessages()
            self.listenForConnections()
        }
        readReceiptManager = ReadReceiptManager(receiverId: chatPartnerId!)
        readReceiptManager?.delegate = self
    }
}

extension ConversationManager: ReadReceiptManagerDelegate {
    func readReceiptManager(_ readRecieptManager: ReadReceiptManager, didUpdate readByIds: [String]) {
        delegate?.conversationManager(self, didUpdate: readByIds)
    }
}

protocol ReadReceiptManagerDelegate {
    func readReceiptManager(_ readRecieptManager: ReadReceiptManager, didUpdate readByIds: [String])
}
