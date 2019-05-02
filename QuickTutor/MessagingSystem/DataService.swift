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
    
    typealias UserCompletion = (User?) -> Void
    typealias TutorCompletion = (ZFTutor?) -> Void
    
    func getUserWithId(_ uid: String, type: UserType, completion: @escaping (User?) -> Void) {
        if type == .tutor {
            getTutorWithId(uid) { tutor in
                completion(tutor)
            }
        } else {
            getStudentWithId(uid) { student in
                completion(student)
            }
        }
    }
    
    func getUserOfOppositeTypeWithId(_ uid: String, completion: @escaping (User?) -> Void) {
        if AccountService.shared.currentUserType == .learner {
            getTutorWithId(uid) { tutor in
                completion(tutor)
            }
        } else {
            getStudentWithId(uid) { student in
                completion(student)
            }
        }
    }
    
    func getUserOfCurrentTypeWithId(_ uid: String, completion: @escaping (User?) -> Void) {
        if AccountService.shared.currentUserType == .tutor {
            getTutorWithId(uid) { tutor in
                completion(tutor)
            }
        } else {
            getStudentWithId(uid) { student in
                completion(student)
            }
        }
    }
    
    func getUserWithUid(_ uid: String, completion: @escaping (User?) -> Void) {
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
        Database.database().reference().child("account").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            Database.database().reference().child("tutor-info").child(uid).observeSingleEvent(of: .value, with: { snapshot2 in
                guard let value2 = snapshot2.value as? [String: Any] else { return }
                let finalDict = value.merging(value2, uniquingKeysWith: { (_, dict2Value) -> Any in
                    dict2Value
                })
                let tutor = ZFTutor(dictionary: finalDict)
                tutor.uid = uid
                guard let img = finalDict["img"] as? [String: Any], let profilePicUrl = img["image1"] as? String else {
                    return }
                tutor.profilePicUrl = URL(string: profilePicUrl)
                tutor.username = finalDict["nm"] as? String
                completion(tutor)
            })
        }
    }
    
    func getStudentWithId(_ uid: String, completion: @escaping TutorCompletion) {
        Database.database().reference().child("account").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            Database.database().reference().child("student-info").child(uid).observeSingleEvent(of: .value, with: { snapshot2 in
                guard let value2 = snapshot2.value as? [String: Any] else { return }
                let finalDict = value.merging(value2, uniquingKeysWith: { (_, dict2Value) -> Any in
                    dict2Value
                })
                let tutor = ZFTutor(dictionary: finalDict)
                tutor.uid = uid
                guard let img = finalDict["img"] as? [String: Any], let profilePicUrl = img["image1"] as? String else {
                    return }
                tutor.profilePicUrl = URL(string: profilePicUrl)
                tutor.username = finalDict["nm"] as? String
                completion(tutor)
            })
        }
    }
    
    func sendMessage(message: UserMessage, toUserId userId: String) {
        
    }
    
    func getMessageById(_ messageId: String, completion: @escaping (UserMessage) -> Void) {
        Database.database().reference().child("messages").child(messageId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let message = UserMessage(dictionary: value)
            message.uid = snapshot.key
            completion(message)
        }
    }
    
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
    
    func sendTextMessage(text: String, receiverId: String, completion: @escaping () -> Void) {
        if text.isEmpty { return }
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        var messageDictionary: [String: Any] = ["text": text, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId]
        messageDictionary["receiverAccountType"] = otherUserTypeString
        let message = UserMessage(dictionary: messageDictionary)
        Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
            let senderRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(receiverId)
            let receiverRef = Database.database().reference().child("conversations").child(receiverId).child(otherUserTypeString).child(uid)
            
            let messageId = ref.key!
            ref.updateChildValues(["uid": messageId])
            senderRef.updateChildValues([messageId: 1])
            receiverRef.updateChildValues([messageId: 1])
            self.updateConversationMetaData(message: message, partnerId: message.partnerId(), messageId: messageId)
            
            completion()
        }
    }
    
    func sendInvisibleMessage(text: String, receiverId: String, completion: @escaping (String?) -> Void) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        var messageDictionary: [String: Any] = ["text": text, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId]
        messageDictionary["receiverAccountType"] = otherUserTypeString
        let message = UserMessage(dictionary: messageDictionary)
        Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
            
            let messageId = ref.key!
            ref.updateChildValues(["uid": messageId])
            self.updateConversationMetaData(message: message, partnerId: message.partnerId(), messageId: messageId)
            let readReceiptManager = ReadReceiptManager(receiverId: receiverId)
            readReceiptManager.invalidateReadReceipt()
            completion(messageId)
        }
    }
    
    func sendImageMessage(imageUrl: String, imageWidth: CGFloat, imageHeight: CGFloat, receiverId: String, completion: @escaping () -> Void) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        var messageDictionary: [String: Any] = ["imageUrl": imageUrl, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId, "imageWidth": imageWidth, "imageHeight": imageHeight]
        messageDictionary["receiverAccountType"] = otherUserTypeString
        let message = UserMessage(dictionary: messageDictionary)
        Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
            let senderRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(receiverId)
            let receiverRef = Database.database().reference().child("conversations").child(receiverId).child(otherUserTypeString).child(uid)
            
            let messageId = ref.key!
            ref.updateChildValues(["uid": messageId])
            senderRef.updateChildValues([messageId: 1])
            receiverRef.updateChildValues([messageId: 1])
            self.updateConversationMetaData(message: message, partnerId: message.partnerId(), messageId: messageId)
            completion()
        }
    }
    
    func sendVideoMessage(thumbnailUrl: URL, thumbnailWidth: CGFloat, thumbnailHeight: CGFloat, videoUrl: URL, receiverId: String, completion: @escaping () -> Void) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        var messageDictionary: [String: Any] = ["imageUrl": thumbnailUrl.absoluteString, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId, "imageWidth": thumbnailWidth, "imageHeight": thumbnailHeight, "videoUrl": videoUrl.absoluteString]
        messageDictionary["receiverAccountType"] = otherUserTypeString
        let message = UserMessage(dictionary: messageDictionary)
        Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
            let senderRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(receiverId)
            let receiverRef = Database.database().reference().child("conversations").child(receiverId).child(otherUserTypeString).child(uid)
            
            let messageId = ref.key!
            ref.updateChildValues(["uid": messageId])
            senderRef.updateChildValues([messageId: 1])
            receiverRef.updateChildValues([messageId: 1])
            self.updateConversationMetaData(message: message, partnerId: message.partnerId(), messageId: messageId)
            completion()
        }
    }
    
    func sendDocumentMessage(documentUrl: String, receiverId: String, completion: @escaping () -> Void) {
        guard let uid = AccountService.shared.currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        var messageDictionary: [String: Any] = ["documentUrl": documentUrl, "timestamp": timestamp, "senderId": uid, "receiverId": receiverId]
        messageDictionary["receiverAccountType"] = otherUserTypeString
        let message = UserMessage(dictionary: messageDictionary)
        Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
            let senderRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(receiverId)
            let receiverRef = Database.database().reference().child("conversations").child(receiverId).child(otherUserTypeString).child(uid)
            
            let messageId = ref.key!
            ref.updateChildValues(["uid": messageId])
            senderRef.updateChildValues([messageId: 1])
            receiverRef.updateChildValues([messageId: 1])
            self.updateConversationMetaData(message: message, partnerId: message.partnerId(), messageId: messageId)
            completion()
        }
    }

    
    func sendTextMessage(_ message: UserMessage, metaData: [String: Any]?) {
        if let metaData = metaData {
            message.data = message.data.merging(metaData) { $1 }
        }
    }
    
    func sendConnectionRequestToId(text: String, _ id: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let expiration = Calendar.current.date(byAdding: .day, value: 7, to: Date())?.timeIntervalSince1970 else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        var values: [String: Any] = ["expiration": expiration, "status": "pending"]
        values["receiverAccountType"] = otherUserTypeString
        let timestamp = Date().timeIntervalSince1970
        Database.database().reference().child("connectionRequests").childByAutoId().setValue(values) { _, ref in
            let message = UserMessage(dictionary: ["text": text, "timestamp": timestamp, "senderId": uid, "receiverId": id, "connectionRequestId": ref.key!, "receiverAccountType": otherUserTypeString])
            Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
                let senderRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(id)
                let receiverRef = Database.database().reference().child("conversations").child(id).child(otherUserTypeString).child(uid)
                
                let messageId = ref.key!
                ref.updateChildValues(["uid": messageId])
                senderRef.updateChildValues([messageId: 1])
                receiverRef.updateChildValues([messageId: 1])
                self.updateConversationMetaData(message: message, partnerId: message.partnerId(), messageId: messageId)
            }
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
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        values["receiverAccountType"] = otherUserTypeString
        let timestamp = Date().timeIntervalSince1970
        Database.database().reference().child("sessions").childByAutoId().setValue(sessionRequest.dictionaryRepresentation) { _, ref1 in
            let messageData: [String: Any] = ["timestamp": timestamp, "senderId": uid, "receiverId": id, "sessionRequestId": ref1.key!, "receiverAccountType": otherUserTypeString]
            let message = UserMessage(dictionary: messageData)
            Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
                let senderRef = Database.database().reference().child("conversations").child(uid).child(userTypeString).child(id)
                let receiverRef = Database.database().reference().child("conversations").child(id).child(otherUserTypeString).child(uid)
                
                let senderSessionRef = Database.database().reference().child("userSessions").child(uid).child(userTypeString)
                let receiverSessionRef = Database.database().reference().child("userSessions").child(id).child(otherUserTypeString)
                
                let messageId = ref.key!
                ref.updateChildValues(["uid": messageId])
                senderRef.updateChildValues([messageId: 1])
                receiverRef.updateChildValues([messageId: 1])
                
                senderSessionRef.updateChildValues([ref1.key!: 1])
                receiverSessionRef.updateChildValues([ref1.key!: 1])
                self.updateConversationMetaData(message: message, partnerId: message.partnerId(), messageId: messageId)
                
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
        
        let userTypeString = AccountService.shared.currentUserType.rawValue
        let otherUserTypeString = AccountService.shared.currentUserType == .learner ? UserType.tutor.rawValue : UserType.learner.rawValue
        Database.database().reference().child("conversationMetaData").child(uid).child(userTypeString).child(partnerId).setValue(metaData)
        Database.database().reference().child("conversationMetaData").child(partnerId).child(otherUserTypeString).child(uid).setValue(metaData)
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
                DataService.shared.getMessageById(child.key, completion: { message in
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
    
    func featchMainPageFeaturedSubject(completion: @escaping([MainPageFeaturedItem]?) -> Void) {
        let myGroup = DispatchGroup()
        var subjects = [MainPageFeaturedItem]()
        Database.database().reference().child("featuredSubjects").observeSingleEvent(of: .value) { (snapshot) in
            guard let subjectsIn = snapshot.value as? [String: Any] else { return }
            subjectsIn.forEach({ (_, childValueIn) in
                myGroup.enter()
                guard let childValue = childValueIn as? [String: Any],
                    let backgroundImageUrl = childValue["imgUrl"] as? String,
                    let title = childValue["title"] as? String,
                    let url = URL(string: backgroundImageUrl)
                    else {
                        myGroup.leave()
                        return
                }
                let subject = childValue["subject"] as? String
                let subcategoryTitle = childValue["subcategory"] as? String
                let categoryTitle = childValue["category"] as? String
                let featuredSubject = MainPageFeaturedItem(subject: subject, backgroundImageUrl: url, title: title, subcategoryTitle: subcategoryTitle, categoryTitle: categoryTitle)
                subjects.append(featuredSubject)
                myGroup.leave()
                
            })
            
            myGroup.notify(queue: .main, execute: {
                completion(subjects)
            })
        }

    }
    
    func setFeaturedSubjectNow() {
        let dict = ["subject": "Cooking", "imgUrl": "https://firebasestorage.googleapis.com/v0/b/quicktutor-3c23b.appspot.com/o/adult-blond-board-298926.jpg?alt=media&token=316575cc-debf-4e9b-9cee-c50e1faa514e"]
        Database.database().reference().child("featuredSubjects").childByAutoId().setValue(dict)
    }
}

class TutorSearchService {
    static let shared = TutorSearchService()
    
    func getTutorsByCategory(_ categoryName: String, lastKnownKey: String?, completion: @escaping ([AWTutor]?, Bool) -> Void) {
        var tutors = [AWTutor]()
        let myGroup = DispatchGroup()
        var ref = Database.database().reference().child("categories").child(categoryName).queryOrderedByKey().queryLimited(toFirst: 60)
        if let key = lastKnownKey {
            ref = ref.queryStarting(atValue: key)
        }
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let tutorIds = snapshot.value as? [String: Any] else { return }
            tutorIds.forEach({ uid, _ in
                myGroup.enter()
                FirebaseData.manager.fetchTutor(uid, isQuery: false, { tutor in
                    guard let tutor = tutor else {
                        myGroup.leave()
                        return
                    }
                    if tutor.uid != Auth.auth().currentUser?.uid {
                        tutor.featuredSubject = tutor.subjects?.first(where: { (subject) -> Bool in
                            let category = CategoryFactory.shared.getCategoryFor(subject: subject)
                            return category?.name == categoryName
                        })
                        tutors.append(tutor)
                    }
                    myGroup.leave()
                })
            })
            myGroup.notify(queue: .main) {
                if let _ = lastKnownKey {
                    tutors.removeFirst()
                }
                completion(tutors, tutorIds.count < 60)
            }
        }
    }
    
    func getTutorsBySubcategory(_ subcategoryName: String, lastKnownKey: String?, completion: @escaping ([AWTutor]?, Bool) -> Void) {
        var tutors = [AWTutor]()
        let desiredSubjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: subcategoryName)

       var ref = Database.database().reference().child("subcategories").child(subcategoryName.lowercased()).queryOrderedByKey().queryLimited(toFirst: 60)
        if let key = lastKnownKey {
            ref = ref.queryStarting(atValue: key)
        }
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.key)
            guard let tutorIds = snapshot.value as? [String: Any] else { return }
            let myGroup = DispatchGroup()
            tutorIds.forEach({ uid, _ in
                myGroup.enter()
                FirebaseData.manager.fetchTutor(uid, isQuery: false, { tutor in
                    guard let tutor = tutor else {
                        myGroup.leave()
                        return
                    }
                    tutor.featuredSubject = tutor.subjects?.first(where: { (subject) -> Bool in
                        return desiredSubjects?.contains(subject) ?? false
                    })
                    if tutor.uid != Auth.auth().currentUser?.uid {
                        tutors.append(tutor)
                    }
                    myGroup.leave()
                })
            })
            myGroup.notify(queue: .main, execute: {
                if let _ = lastKnownKey {
                    tutors.removeFirst()
                }
                completion(tutors, tutorIds.count < 60)
            })
        })
    }
    
    func getTutorsBySubject(_ subject: String, lastKnownKey: String?, completion: @escaping ([AWTutor]?, Bool) -> Void) {
        var tutors = [AWTutor]()
        let myGroup = DispatchGroup()
        var ref = Database.database().reference().child("subjects").child(subject).queryOrderedByKey().queryLimited(toFirst: 60)
        
        if let key = lastKnownKey {
            ref = ref.queryStarting(atValue: key)
        }
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let tutorIds = snapshot.value as? [String: Any] else { return }
            tutorIds.forEach({ uid, _ in
                myGroup.enter()
                FirebaseData.manager.fetchTutor(uid, isQuery: false, { tutor in
                    guard let tutor = tutor else {
                        myGroup.leave()
                        return
                    }
                    tutor.featuredSubject = subject
                    if tutor.uid != Auth.auth().currentUser?.uid {
                        tutors.append(tutor)
                    }
                    myGroup.leave()
                })
            })
            myGroup.notify(queue: .main, execute: {
                if let _ = lastKnownKey {
                    tutors.removeFirst()
                }
                completion(tutors, tutorIds.count < 60)
            })
        }
    }
    
    func getTopTutors(completion: @escaping([AWTutor]) -> Void) {
        Database.database().reference().child("tutor-info").queryOrdered(byChild: "nos").queryLimited(toLast: 25).observeSingleEvent(of: .value) { (snapshot) in
            guard let tutorsDict = snapshot.value as? [String: Any] else { return }
            let group = DispatchGroup()
            var tutors = [AWTutor]()
            tutorsDict.forEach({ (key, value) in
                group.enter()
                FirebaseData.manager.fetchTutor(key, isQuery: false, { (tutor) in
                    guard let tutor = tutor else {
                        print("Couldn't fetch tutor for", key)
                        group.leave()
                        return
                    }
                    if tutor.uid != Auth.auth().currentUser?.uid {
                        tutors.append(tutor)
                    }
                    group.leave()
                })
            })
            
            group.notify(queue: .main, execute: {
                completion(tutors)
            })
        }
    }
    
    func getRecommendedTutors(completion: @escaping ([AWTutor]) -> Void) {
        fetchSessions { (sessions) in
            var tutors = [AWTutor]()
            let group = DispatchGroup()
            sessions.forEach({ (session) in
                group.enter()
                self.getTutorsBySubject(session.subject, lastKnownKey: nil, completion: { (sessionTutors, _) in
                    guard let sessionTutors = sessionTutors else {
                        group.leave()
                        return
                    }
                    tutors += sessionTutors
                    group.leave()
                })
            })
            group.notify(queue: .main, execute: {
                completion(tutors)
            })

        }
    }
    
    func getCurrentlyOnlineTutors(completion: @escaping ([AWTutor]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("userStatus").queryOrdered(byChild: "status").queryEqual(toValue: 2).observeSingleEvent(of: .value) { (snapshot) in
            guard let uids = snapshot.value as? [String: Any] else { return }
            var tutors = [AWTutor]()
            let group = DispatchGroup()
            uids.forEach({ (key,value) in
                group.enter()
                FirebaseData.manager.fetchTutor(key, isQuery: false, { (tutor) in
                    guard let tutor = tutor, tutor.uid != uid else {
                        group.leave()
                        return
                    }
                    
                    tutors.append(tutor)
                    group.leave()
                })
            })
            
            group.notify(queue: .main, execute: {
                completion(tutors)
            })
            
        }
    }
    
    func fetchSessions(completion: @escaping ([Session]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
        var sessions = [Session]()
        let group = DispatchGroup()
        Database.database().reference().child("userSessions").child(uid).child(userTypeString).observe(.childAdded) { snapshot in
            group.enter()
            DataService.shared.getSessionById(snapshot.key, completion: { session in
                sessions.append(session)
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            completion(sessions)
        }
    }
    
    private init() {}
}

class DataBaseCleaner {
    static let shared = DataBaseCleaner()
    
    func sendFeaturedTutorsToCorrectNode() {
        Database.database().reference().child("subcategory").observe(.childAdded) { snapshot in
            guard let category = snapshot.value as? [String: [String: Any]] else {
                print("Error with categories")
                return
            }
            
            category.forEach({ uid, _ in
                Database.database().reference().child("subcategories").child(snapshot.key).child(uid).setValue(1)
            })
        }
    }
    
    func setSubjectsToCorrectNode() {
        Database.database().reference().child("subject").observe(.childAdded) { snapshot in
            guard let userProfile = snapshot.value as? [String: [String: Any]] else {
                print("Error with categories")
                return
            }
            
            userProfile.forEach({ _, userData in
                guard let subjectsString = userData["sbj"] as? String else {
                    print("Error with subjects string")
                    return
                }
                
                let subjects = subjectsString.components(separatedBy: "$")
                print(subjects)
                subjects.forEach({ subject in
                    print(subject)
                    print(snapshot.key)
                    let formattedSubject = subject.replacingOccurrences(of: "#", with: "sharp").replacingOccurrences(of: ".", with: "dot")
                    Database.database().reference().child("subjects").child(formattedSubject).child(snapshot.key).setValue(1)
                })
            })
        }
    }
    
    func setFeaturedSubjectsForTutors() {
        Database.database().reference().child("featured").observe(.childAdded) { snapshot in
            guard let category = snapshot.value as? [String: [String: Any]] else {
                print("Error with categories")
                return
            }
            
            category.forEach({ userId, userData in
                guard let subject = userData["sbj"] as? String else { return }
                print(subject)
                Database.database().reference().child("tutor-info").child(userId).child("sbj").setValue(subject)
            })
        }
    }
    
    func restructureTutorSubjects() {
        Database.database().reference().child("subject").observe(.childAdded) { (snapshot) in
            guard let subcategoryList = snapshot.value as? [String: Any] else {
                print("Error with subcategory")
                return
            }
            
            subcategoryList.forEach({ (key, value) in
                guard let data = value as? [String: Any] else { return }
                guard let subjectString = data["sbj"] as? String else {
                    print("Error with subject string for id:", key)
                    return
                }
                let subjects = subjectString.split(separator: "$")
                let ref = Database.database().reference().child("tutor-info").child(snapshot.key).child("subjects")
                subjects.forEach({ (subject) in
                let formattedSubject = subject.replacingOccurrences(of: "#", with: "sharp").replacingOccurrences(of: ".", with: "dot")
                    ref.child(String(formattedSubject)).setValue(1)
                })
            })
            

        }
    }
    
    
    private init() {}
}
