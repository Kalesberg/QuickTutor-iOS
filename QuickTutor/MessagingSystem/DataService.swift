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
    
    typealias UserCompletion = (User?) -> ()
    typealias TutorCompletion = (ZFTutor?) -> ()
    
    func getUserOfOppositeTypeWithId(_ uid: String, completion: @escaping(User?) -> ()) {
        if AccountService.shared.currentUserType == .learner {
            getTutorWithId(uid) { (tutor) in
                completion(tutor)
            }
        } else {
            getStudentWithId(uid) { (student) in
                completion(student)
            }
        }
    }
    
    func getUserWithUid(_ uid: String, completion: @escaping (User?) -> ()) {
        Database.database().reference().child("account").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            let user = User(dictionary: value)
            user.uid = uid
            completion(user)
        }
    }
    
    func getTutorWithId(_ uid: String, completion: @escaping TutorCompletion) {
        Database.database().reference().child("account").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else { return }
            Database.database().reference().child("tutor-info").child(uid).observeSingleEvent(of: .value, with: { (snapshot2) in
                guard let value2 = snapshot2.value as? [String: Any] else { return }
                let finalDict = value.merging(value2, uniquingKeysWith: { (dict1Value, dict2Value) -> Any in
                    return dict2Value
                })
                let tutor = ZFTutor(dictionary: finalDict)
                tutor.uid = uid
                guard let img = finalDict["img"] as? [String: Any], let profilePicUrl = img["image1"] as? String else {
                    return }
                tutor.profilePicUrl = profilePicUrl
                tutor.username = finalDict["nm"] as? String
                completion(tutor)
            })
        }
    }
    
    func getStudentWithId(_ uid: String, completion: @escaping TutorCompletion) {
        Database.database().reference().child("account").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else { return }
            Database.database().reference().child("student-info").child(uid).observeSingleEvent(of: .value, with: { (snapshot2) in
                guard let value2 = snapshot2.value as? [String: Any] else { return }
                let finalDict = value.merging(value2, uniquingKeysWith: { (dict1Value, dict2Value) -> Any in
                    return dict2Value
                })
                let tutor = ZFTutor(dictionary: finalDict)
                tutor.uid = uid
                guard let img = finalDict["img"] as? [String: Any], let profilePicUrl = img["image1"] as? String else {
                    return }
                tutor.profilePicUrl = profilePicUrl
                tutor.username = finalDict["nm"] as? String
                completion(tutor)
            })
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
    
    func getSessionById(_ sessionId: String, completion: @escaping(Session) -> ()) {
        Database.database().reference().child("sessions").child(sessionId).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else { return }
            let session = Session(dictionary: value, id: sessionId)
            completion(session)
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
    
    func sendSessionRequestToId(sessionRequest: SessionRequest, _ id: String) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        
        guard let expiration = Calendar.current.date(byAdding: .day, value: 7, to: Date())?.timeIntervalSince1970 else { return }
        
        let _: [String: Any] = ["expiration": expiration, "status": "pending"]
        
        let timestamp = Date().timeIntervalSince1970
        Database.database().reference().child("sessions").childByAutoId().setValue(sessionRequest.dictionaryRepresentation) { (error, ref1) in
            let message = UserMessage(dictionary: ["timestamp": timestamp, "senderId": uid, "receiverId": id, "sessionRequestId": ref1.key])
            Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
                let senderRef = Database.database().reference().child("conversations").child(uid).child(id)
                let receiverRef = Database.database().reference().child("conversations").child(id).child(uid)
                
                let senderSessionRef = Database.database().reference().child("userSessions").child(uid)
                let receiverSessionRef = Database.database().reference().child("userSessions").child(id)
                
                let messageId = ref.key
                ref.updateChildValues(["uid": ref.key])
                senderRef.updateChildValues([messageId: 1])
                receiverRef.updateChildValues([messageId: 1])
                
                senderSessionRef.updateChildValues([ref1.key: 1])
                receiverSessionRef.updateChildValues([ref1.key: 1])
                
            }
        }
    }
}
