//
//  MessageService.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/12/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

class MessageService {
    
    static let shared = MessageService()
    var userTypeString: String {
        return AccountService.shared.currentUserType.rawValue
    }
    var otherUserTypeString: String {
        return AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
    }    
    
    func getMessageById(_ messageId: String, completion: @escaping (UserMessage) -> Void) {
        Database.database().reference().child("messages").child(messageId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let message = UserMessage(dictionary: value)
            message.uid = snapshot.key
            completion(message)
        }
    }
    
    func sendTextMessage(text: String, receiverId: String, completion: @escaping () -> Void) {
        if text.isEmpty { return }
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        var messageDictionary: [String: Any] = ["text": text, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId]
        messageDictionary["receiverAccountType"] = otherUserTypeString
        let message = UserMessage(dictionary: messageDictionary)
        sendMessage(message, toUserId: receiverId) {
            completion()
        }
    }
    
    func sendInvisibleMessage(text: String, receiverId: String, completion: @escaping (String?) -> Void) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        var messageDictionary: [String: Any] = ["text": text, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId]
        messageDictionary["receiverAccountType"] = otherUserTypeString
        let message = UserMessage(dictionary: messageDictionary)
        guard let partnerId = message.partnerId() else { return }
        Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
            
            let messageId = ref.key!
            ref.updateChildValues(["uid": messageId])
            self.updateConversationMetaData(message: message, partnerId: partnerId, messageId: messageId)
            let readReceiptManager = ReadReceiptManager(receiverId: receiverId)
            readReceiptManager.invalidateReadReceipt()
            completion(messageId)
        }
    }
    
    func sendImageMessage(imageUrl: String, imageWidth: CGFloat, imageHeight: CGFloat, receiverId: String, completion: @escaping () -> Void) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        var messageDictionary: [String: Any] = ["imageUrl": imageUrl, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId, "imageWidth": imageWidth, "imageHeight": imageHeight]
        messageDictionary["receiverAccountType"] = otherUserTypeString
        let message = UserMessage(dictionary: messageDictionary)
        sendMessage(message, toUserId: receiverId) {
            completion()
        }
    }
    
    func sendVideoMessage(thumbnailUrl: URL, thumbnailWidth: CGFloat, thumbnailHeight: CGFloat, videoUrl: URL, receiverId: String, completion: @escaping () -> Void) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let messageDictionary: [String: Any] = ["imageUrl": thumbnailUrl.absoluteString, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId, "imageWidth": thumbnailWidth, "imageHeight": thumbnailHeight, "videoUrl": videoUrl.absoluteString, "receiverAccountType": otherUserTypeString]
        let message = UserMessage(dictionary: messageDictionary)
        sendMessage(message, toUserId: receiverId) {
            completion()
        }
    }
    
    func sendDocumentMessage(documentUrl: String, receiverId: String, completion: @escaping () -> Void) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let messageDictionary: [String: Any] = ["documentUrl": documentUrl, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId, "receiverAccountType": otherUserTypeString]
        let message = UserMessage(dictionary: messageDictionary)
        sendMessage(message, toUserId: receiverId) {
            completion()
        }
    }
    
    private func sendMessage(_ message: UserMessage, toUserId receiverId: String, completion: @escaping() -> Void) {
        guard let currentUser = AccountService.shared.currentUser,
            let uid = currentUser.uid,
            let partnerId = message.partnerId() else { return }
        Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
            let senderRef = Database.database().reference().child("conversations").child(uid).child(self.userTypeString).child(receiverId)
            let receiverRef = Database.database().reference().child("conversations").child(receiverId).child(self.otherUserTypeString).child(uid)
            
            let messageId = ref.key!
            ref.updateChildValues(["uid": messageId])
            senderRef.updateChildValues([messageId: 1])
            receiverRef.updateChildValues([messageId: 1])
            self.updateConversationMetaData(message: message, partnerId: partnerId, messageId: messageId)
            
            completion()
        }
    }
    
    func sendTextMessage(_ message: UserMessage, metaData: [String: Any]?) {
        if let metaData = metaData {
            message.data = message.data.merging(metaData) { $1 }
        }
    }
    
    func sendConnectionRequestToId(text: String, _ id: String, shouldMarkAsRead: Bool = false) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let expiration = Calendar.current.date(byAdding: .day, value: 7, to: Date())?.timeIntervalSince1970 else { return }
        var values: [String: Any] = ["expiration": expiration, "status": "pending"]
        values["receiverAccountType"] = otherUserTypeString
        let timestamp = Date().timeIntervalSince1970
        Database.database().reference().child("connectionRequests").childByAutoId().setValue(values) { _, ref in
            let message = UserMessage(dictionary: ["text": text, "timestamp": timestamp, "senderId": uid, "receiverId": id, "connectionRequestId": ref.key!, "receiverAccountType": self.otherUserTypeString])
            self.sendMessage(message, toUserId: id, completion: {
                if shouldMarkAsRead {                    Database.database().reference().child("conversationMetaData").child(uid).child(self.userTypeString).child(id).child("readBy").child(uid).setValue(true)
                    Database.database().reference().child("conversationMetaData").child(id).child(self.otherUserTypeString).child(uid).child("readBy").child(uid).setValue(true)
                }
            })
        }
    }
    
    func sendSessionRequestToId(sessionRequest: SessionRequest, _ id: String) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        SessionAnalyticsService.shared.logSessionRequestSent(sessionRequest)
        guard sessionRequest.endTime != 0 else { return }
        let expiration = (sessionRequest.endTime - Date().timeIntervalSince1970) / 2
        let expirationDate = Date().addingTimeInterval(expiration).timeIntervalSince1970
        sessionRequest.expiration = expirationDate
        var values: [String: Any] = ["expiration": expirationDate, "status": "pending"]
        values["receiverAccountType"] = otherUserTypeString
        let timestamp = Date().timeIntervalSince1970
        Database.database().reference().child("sessions").childByAutoId().setValue(sessionRequest.dictionaryRepresentation) { _, ref1 in
            let messageData: [String: Any] = ["timestamp": timestamp, "senderId": uid, "receiverId": id, "sessionRequestId": ref1.key!, "receiverAccountType": self.otherUserTypeString]
            let message = UserMessage(dictionary: messageData)
            guard let partnerId = message.partnerId() else { return }
            Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
                let senderRef = Database.database().reference().child("conversations").child(uid).child(self.userTypeString).child(id)
                let receiverRef = Database.database().reference().child("conversations").child(id).child(self.otherUserTypeString).child(uid)
                
                let senderSessionRef = Database.database().reference().child("userSessions").child(uid).child(self.userTypeString)
                let receiverSessionRef = Database.database().reference().child("userSessions").child(id).child(self.otherUserTypeString)
                
                let messageId = ref.key!
                ref.updateChildValues(["uid": messageId])
                senderRef.updateChildValues([messageId: 1])
                receiverRef.updateChildValues([messageId: 1])
                
                senderSessionRef.updateChildValues([ref1.key!: 1])
                receiverSessionRef.updateChildValues([ref1.key!: 1])
                self.updateConversationMetaData(message: message, partnerId: partnerId, messageId: messageId)
            }
        }
    }
    
    func updateConversationMetaData(message: UserMessage, partnerId: String, messageId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var metaData = [String: Any]()
        metaData["lastUpdatedAt"] = message.timeStamp
        metaData["lastMessageSenderId"] = uid
        metaData["lastMessageContent"] = message.text ?? ""
        metaData["lastMessageProfilePicUrl"] = message.user?.profilePicUrl.absoluteString ?? ""
        metaData["lastMessageUsername"] = message.user?.username ?? ""
        metaData["lastMessageId"] = messageId
        metaData["memberIds"] = [uid, partnerId]
        
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(partnerId).setValue(metaData)
        Database.database().reference().child("conversationMetaData").child(partnerId).child(otherUserTypeString).child(uid).setValue(metaData)
    }
}
