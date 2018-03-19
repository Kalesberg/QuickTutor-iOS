//
//  DataService.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    static let shared = DataService()
    private init() {}
    
    func getUserWithUid(_ uid: String, completion: @escaping (User?) -> ()) {
        Database.database().reference().child("accounts").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("Snapshot was empty")
                completion(nil)
                return
            }
            let user = User(dictionary: value)
            user.uid = uid
            completion(user)
        }
    }
    
    func sendMessage(message: UserMessage, toUserId userId: String) {
        
    }
    
    func getMessageById(_ messageId: String, completion: @escaping (UserMessage) -> ()) {
        Database.database().reference().child("messages").child(messageId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let message = UserMessage(dictionary: value)
            message.uid = snapshot.key
            completion(message)
        }
    }
    
    func sendTextMessage(text: String, receiverId: String, completion: @escaping () -> ()) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let message = UserMessage(dictionary: ["text": text, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId])
        Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
            let senderRef = Database.database().reference().child("conversations").child(uid).child(receiverId)
            let receiverRef = Database.database().reference().child("conversations").child(receiverId).child(uid)
            
            let messageId = ref.key
            ref.updateChildValues(["uid": ref.key])
            senderRef.updateChildValues([messageId: 1])
            receiverRef.updateChildValues([messageId: 1])
            completion()
        }
    }
    
    func sendImageMessage(imageUrl: String, imageWidth: CGFloat, imageHeight: CGFloat, receiverId: String, completion: @escaping () -> ()) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let message = UserMessage(dictionary: ["imageUrl": imageUrl, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId, "imageWidth": imageWidth, "imageHeight": imageHeight])
        Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
            let senderRef = Database.database().reference().child("conversations").child(uid).child(receiverId)
            let receiverRef = Database.database().reference().child("conversations").child(receiverId).child(uid)
            
            let messageId = ref.key
            ref.updateChildValues(["uid": ref.key])
            senderRef.updateChildValues([messageId: 1])
            receiverRef.updateChildValues([messageId: 1])
            completion()
        }
    }

    
    func sendConnectionRequestToId(text: String, _ id: String) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        
        guard let expiration = Calendar.current.date(byAdding: .day, value: 7, to: Date())?.timeIntervalSince1970 else { return }
        let values: [String: Any] = ["expiration": expiration, "status": "pending"]
        
        let timestamp = Date().timeIntervalSince1970
        Database.database().reference().child("connectionRequests").childByAutoId().setValue(values) { (error, ref) in
            let message = UserMessage(dictionary: ["text": text, "timestamp": timestamp, "senderId": uid, "receiverId": id, "connectionRequestId": ref.key])
            Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
                let senderRef = Database.database().reference().child("conversations").child(uid).child(id)
                let receiverRef = Database.database().reference().child("conversations").child(id).child(uid)
                
                let messageId = ref.key
                ref.updateChildValues(["uid": ref.key])
                senderRef.updateChildValues([messageId: 1])
                receiverRef.updateChildValues([messageId: 1])
            }
        }
    }
    
    func sendMeetupRequestToId(meetupRequest: MeetupRequest, _ id: String) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        
        guard let expiration = Calendar.current.date(byAdding: .day, value: 7, to: Date())?.timeIntervalSince1970 else { return }
        
        let values: [String: Any] = ["expiration": expiration, "status": "pending"]
        
        let timestamp = Date().timeIntervalSince1970
        Database.database().reference().child("meetupRequests").childByAutoId().setValue(meetupRequest.dictionaryRepresentation) { (error, ref) in
            let message = UserMessage(dictionary: ["timestamp": timestamp, "senderId": uid, "receiverId": id, "meetupRequestId": ref.key])
            Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
                let senderRef = Database.database().reference().child("conversations").child(uid).child(id)
                let receiverRef = Database.database().reference().child("conversations").child(id).child(uid)
                
                
                let messageId = ref.key
                ref.updateChildValues(["uid": ref.key])
                senderRef.updateChildValues([messageId: 1])
                receiverRef.updateChildValues([messageId: 1])
            }
        }
    }
}
