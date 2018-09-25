//
//  ConversationManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

class ConnectionManager {
    func createConnectionWith(uid _: String) {}

    func removeConnectionWith(uid _: String) {}

    func getAllConnectedIds() {}
}

class ConversationManager {
    weak var delegate: ConversationManagerDelegate?
    var metaData: ConversationMetaData?
    var memberIds: [String]?
    var readByIds: [String]?
    var messages = [BaseMessage]()
    var chatPartnerId: String?
    var chatPartner: User?
    var canSendMessage = true
    var isConnected = false
    var uid: String!
    var earliestLoadedMessageId: String?
    var isFinishedPaginating = true
    var loadedAllMessages = false
    var isInitialLoad = true
    var lastSendMessageIndex = -1

    var readReceiptManager: ReadReceiptManager?

    func loadPreviousMessagesByTimeStamp(limit: Int, completion: @escaping ([UserMessage]) -> Void) {
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

        var previousMessages = [UserMessage]()
        query.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                self.delegate?.conversationManager(self, didLoadAll: self.messages)
                completion([UserMessage]())
                return
            }
            var fetchedMessageCount = 0
            if children.count == 0 {
                self.messageAlreadyLoaded = false
                completion([UserMessage]())
            }
            if children.count < limit {
                self.loadedAllMessages = true
            }
            for child in children {
                DataService.shared.getMessageById(child.key, completion: { message in
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

    var messageAlreadyLoaded = true
    func listenForNewMessages() {
        let query = getConversationQueryRef()
        query.observe(.childAdded) { snapshot in
            let messageId = snapshot.key
            guard !self.messageAlreadyLoaded else {
                self.messageAlreadyLoaded = false
                return
            }
            DataService.shared.getMessageById(messageId, completion: { message in
                self.messages.append(message)

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
        if messages.count == 0 {
            return nil
        }

        var location = -1
        var index = 0
        for message in messages {
            location += 1
            guard let userMessage = message as? UserMessage else { continue }
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
        loadPreviousMessagesByTimeStamp(limit: 50) { _ in
            self.listenForNewMessages()
            self.listenForConnections()
        }
        readReceiptManager = ReadReceiptManager(receiverId: chatPartnerId!)
        readReceiptManager?.delegate = self
    }
}

extension ConversationManager: ReadReceiptManagerDelegate {
    func readReceiptManager(_: ReadReceiptManager, didUpdate readByIds: [String]) {
        delegate?.conversationManager(self, didUpdate: readByIds)
    }
}

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

protocol ConversationManagerDelegate: class {
    func conversationManager(_ conversationManager: ConversationManager, didReceive message: UserMessage)
    func conversationManager(_ conversationManager: ConversationManager, didLoad messages: [BaseMessage])
    func conversationManager(_ conversationManager: ConversationManager, didUpdate readByIds: [String])
    func conversationManager(_ convesationManager: ConversationManager, didUpdateConnection connected: Bool)
    func conversationManager(_ conversationManager: ConversationManager, didLoadAll messages: [BaseMessage])
}

protocol ReadReceiptManagerDelegate {
    func readReceiptManager(_ readRecieptManager: ReadReceiptManager, didUpdate readByIds: [String])
}
