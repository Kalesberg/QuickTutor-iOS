//
//  DataService.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import Firebase
import Foundation

class DataService {
    static let shared = DataService()
    private init() {}
    
    func getSessionById(_ sessionId: String, completion: @escaping (Session) -> Void) {
        Database.database().reference().child("sessions").child(sessionId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(Session(dictionary: [:], id: sessionId))
                return
            }
            let session = Session(dictionary: value, id: sessionId)
            completion(session)
        }
    }
    
    func uploadImageToFirebase(image: UIImage, completion: @escaping (String) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.2) else {
            return
        }
        let imageName = NSUUID().uuidString
        
        let metaDataDictionary = ["width": image.size.width, "height": image.size.height]
        let metaData = StorageMetadata(dictionary: metaDataDictionary)
        
        Storage.storage().reference().child(imageName).putData(data, metadata: metaData) { _, _ in
            // guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            completion("imageUrl")
        }
    }
    
    func loadInitialMessagesForUserId(_ chatPartnerId: String, lastMessageId: String, completion: @escaping ([BaseMessage]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var messages = [BaseMessage]()
        let userTypeString = AccountService.shared.currentUserType.rawValue
        
        let ref = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(chatPartnerId)
        var query = ref.queryOrderedByKey()
        query = query.queryEnding(atValue: lastMessageId).queryLimited(toLast: UInt(50))
        query.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
            var fetchedMessageCount = 0
            for child in children {
                MessageService.shared.getMessageById(child.key, completion: { message in
                    messages.append(message)
                    fetchedMessageCount += 1
                    if fetchedMessageCount == children.count {
                        completion(messages)
                    }
                })
            }
        }
    }
    
    func checkUnreadMessagesForUser(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).observe(.value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
            var hasUnreadMessages = false
            for child in children {
                guard let metaDataIn = child.value as? [String: Any] else { return }
                
                let metaData = ConversationMetaData(dictionary: metaDataIn)
                if let read = metaData.hasRead, !read, let _ = metaData.lastMessageId {
                    hasUnreadMessages = true
                }
            }
            completion(hasUnreadMessages)
        }
    }
    
    func getConversationMetaDataForUid(_ partnerId: String, completion: @escaping (ConversationMetaData?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(partnerId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            let metaData = ConversationMetaData(dictionary: value)
            completion(metaData)
        }
    }
    
    func featchMainPageFeaturedSubject(completion: @escaping([MainPageFeaturedItem]) -> Void) {
        var subjects: [MainPageFeaturedItem] = []
        Database.database().reference().child("featuredSubjects").observeSingleEvent(of: .value) { (snapshot) in
            guard let dicSubjects = snapshot.value as? [String: Any] else {
                completion(subjects)
                return
            }
            
            dicSubjects.values.forEach { dicFeature in
                guard let dicFeature = dicFeature as? [String: Any],
                    let imgUrl = dicFeature["imgUrl"] as? String,
                    let strTitle = dicFeature["title"] as? String,
                    let url = URL(string: imgUrl) else {
                        completion(subjects)
                        return
                }
                
                let subject = dicFeature["subject"] as? String
                let subcategoryTitle = dicFeature["subcategory"] as? String
                let categoryTitle = dicFeature["category"] as? String
                let featuredSubject = MainPageFeaturedItem(subject: subject, backgroundImageUrl: url, title: strTitle, subcategoryTitle: subcategoryTitle, categoryTitle: categoryTitle)
                subjects.append(featuredSubject)
            }
            
            completion(subjects)
        }
    }
    
    func setFeaturedSubjectNow() {
        let dict = ["subject": "Cooking", "imgUrl": "https://firebasestorage.googleapis.com/v0/b/quicktutor-3c23b.appspot.com/o/adult-blond-board-298926.jpg?alt=media&token=316575cc-debf-4e9b-9cee-c50e1faa514e"]
        Database.database().reference().child("featuredSubjects").childByAutoId().setValue(dict)
    }
    
    func sendQuickCallRequestToId(sessionRequest: SessionRequest, _ id: String, completion: (() -> ())?) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        SessionAnalyticsService.shared.logSessionRequestSent(sessionRequest)
        guard sessionRequest.endTime != 0 else { return }
        let expiration = (sessionRequest.endTime - Date().timeIntervalSince1970) / 2
        let expirationDate = Date().addingTimeInterval(expiration).timeIntervalSince1970
        sessionRequest.expiration = expirationDate
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        
        NotificationManager.shared.disableAllNotifications()
        
        Database.database().reference().child("sessions").childByAutoId().setValue(sessionRequest.dictionaryRepresentation) { _, ref1 in
            
            // TODO: When implement quick call on conversation screen, should udpate messages, conversations and converstation meta data as well
            
            let senderSessionRef = Database.database().reference().child("userSessions").child(uid).child(userTypeString)
            let receiverSessionRef = Database.database().reference().child("userSessions").child(id).child(otherUserTypeString)
            
            senderSessionRef.updateChildValues([ref1.key!: 0])
            receiverSessionRef.updateChildValues([ref1.key!: 0])
            
            let value: [String : Any] = ["startedBy": uid, "startType": "manual", "sessionType": QTSessionType.quickCalls.rawValue]
            Database.database().reference().child("sessionStarts").child(uid).child(ref1.key!).setValue(value)
            Database.database().reference().child("sessionStarts").child(sessionRequest.partnerId()).child(ref1.key!).setValue(value)
            
            // remove local notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [ref1.key!])
            
            if let completion = completion {
                completion()
            }
        }
    }
}
