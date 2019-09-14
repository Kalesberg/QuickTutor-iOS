//
//  QTQuickRequestService.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class QTQuickRequestService {
    static let shared = QTQuickRequestService()
    
    var subject: String?
    var sessionType: QTSessionType = .online
    var startTime: Date = Date().adding(minutes: 15)
    var duration: Int = 20
    var minPrice: Double?
    var maxPrice: Double?
    
    private var tutorQuickRequestsSubjectsHandles: [DatabaseHandle]?
    private var tutorQuickRequestsSubjectsRefs: [DatabaseReference]?
    private var tutorQuickRequestsCategoriesHandles: [DatabaseHandle]?
    private var tutorQuickRequestsCategoriesRefs: [DatabaseReference]?
    private var tutorQuickRequestsSubcategoriesHandles: [DatabaseHandle]?
    private var tutorQuickRequestsSubcategoriesRefs: [DatabaseReference]?
    private var tutorQuickRequestsAppliesHandles: [DatabaseHandle]?
    private var tutorQuickRequestsAppliesRefs: [DatabaseReference]?
    
    var opportunities = [QTQuickRequestModel]()
    var appliedQuickRequestIds = [String]()
    
    func reset() {
        subject = nil
        sessionType = .online
        startTime = Date().adding(minutes: 15)
        duration = 20
        minPrice = nil
        maxPrice = nil
    }
    
    func sendQuickRequest(_ completion: ((Bool?, String?) -> Void)?) {
        
        guard let uid = CurrentUser.shared.learner.uid else {
            if let completion = completion {
                completion(false, "You can't submit the request.")
            }
            return
        }
        var requestData = [String: Any] ()
        requestData["subject"] = subject
        requestData["date"] = startTime.timeIntervalSince1970
        requestData["startTime"] = startTime.timeIntervalSince1970
        let endTime = startTime.adding(minutes: duration).timeIntervalSince1970
        requestData["endTime"] = endTime
        requestData["type"] = sessionType.rawValue
        requestData["minPrice"] = minPrice
        requestData["maxPrice"] = maxPrice
        requestData["expired"] = false
        requestData["senderId"] = uid
        requestData["duration"] = duration * 60
        let expiration = (endTime - Date().timeIntervalSince1970) / 2
        let expirationDate = Date().addingTimeInterval(expiration).timeIntervalSince1970
        requestData["expiration"] = expirationDate
        
        guard let subject = subject else {
            if let completion = completion {
                completion(false, "Please select a subject.")
            }
            return
        }
        
        Database.database().reference().child("quickRequests").childByAutoId().setValue(requestData) { (error, ref) in
            if let error = error {
                if let completion = completion {
                    completion(false, error.localizedDescription)
                    return
                }
            }
            
            if let uid = ref.key {
                ref.updateChildValues(["uid": uid])
                
                // Register the id of quickrequest in quickRequestsSubjects table with the subject as an index
                // in order to search opportunities by the subject simply
                Database.database().reference().child("quickRequestsSubjects")
                    .child(subject.lowercased()).setValue([uid: 1])
                
                // Get the number of tutors in a subject
                Database.database().reference().child("subjects").child(subject).observeSingleEvent(of: .value, with: { (snapshot) in
                    // If there are 50+ tutors, just make the quickrequest as subject quick request.
                    if snapshot.childrenCount >= 50 {
                        if let completion = completion {
                            completion(true, nil)
                        }
                        return
                    }
                    if let subcategory = CategoryFactory.shared.getSubcategoryFor(subject: subject) {
                        // Get the number of tutors in a subcategory
                        Database.database().reference().child("subcategories").child(subcategory.name.lowercased()).observeSingleEvent(of: .value, with: { (subcategorySnapshot) in
                            
                            // If there are 150+ tutors in a subcategory, just make the quickrequest as subcategory quick request.
                            if snapshot.childrenCount >= 150 {
                                // Register the id of quickrequest in quickRequestsSubCategories table with the subcategory which involves the subject as an index in order to search opportunities by the subcategory later if there is none of quickrequests searched by a subject
                                Database.database().reference().child("quickRequestsSubcategories")
                                    .child(subcategory.name.lowercased()).setValue([uid: 1])
                            } else {
                                // If no enough tutors in a subcategory, just make the quickrequest as category quick request.
                                // Register the id of quickrequest in quickRequestsCategories table with the category which involves the subject as an index in order to search opportunities by the category later if there is none of quickrequests searched by a subject or a subcategory
                                Database.database().reference().child("quickRequestsCategories")
                                    .child(subcategory.category.lowercased()).setValue([uid: 1])
                            }
                        })
                        
                        if let completion = completion {
                            completion(true, nil)
                        }
                        return
                    }
                    
                    if let completion = completion {
                        completion(true, nil)
                    }
                })
                return
            }
            
            if let completion = completion {
                completion(false, "Faild to submit the request.")
            }
        }
    }
    
    func applyOpportunity(request: QTQuickRequestModel) {
        // 1. Add a session into sessions table as pending status with quickRequestId
        // 2. Add a message into messages table
        // 3. Add a conversation info into conversations table with message id
        // 4. Add a conversation meta data into conversationMetaData table
        // 5. Connect learner and tutor each other because they should communicate each other before accept a session of quickrequest
        // 6. Save tutorId, sessionId and quickRequestId into quickRequestsApplies table.
        
        guard let tutorId = CurrentUser.shared.tutor.uid,
            let price = request.price,
            let paymentType = request.paymentType,
            let expiration = request.expiration else {
            return
        }
        
        // 1. Add a session into sessions table as pending status with quickRequestId
        let myUserType = UserType.tutor.rawValue
        let partnerType = UserType.learner.rawValue
        var sessionData = [String: Any] ()
        sessionData["subject"] = request.subject
        sessionData["date"] = request.date
        sessionData["startTime"] = request.startTime
        sessionData["endTime"] = request.endTime
        sessionData["type"] = request.type.rawValue
        sessionData["price"] = price
        sessionData["status"] = "pending"
        sessionData["senderId"] = tutorId
        sessionData["receiverId"] = request.senderId // Learner Id
        sessionData["paymentType"] = paymentType.rawValue
        sessionData["duration"] = request.duration
        sessionData["quickRequestId"] = request.id
        sessionData["expiration"] = expiration
        sessionData["receiverAccountType"] = partnerType
        
        let timestamp = Date().timeIntervalSince1970
        Database.database().reference().child("sessions").childByAutoId().setValue(sessionData) { _, ref1 in
            
            // 2. Add a message into messages table
            let messageData: [String: Any] = ["timestamp": timestamp,
                                              "senderId": tutorId,
                                              "receiverId": request.senderId,
                                              "sessionRequestId": ref1.key!,
                                              "receiverAccountType": partnerType]
            let message = UserMessage(dictionary: messageData)
            guard let partnerId = message.partnerId() else { return }
            Database.database().reference().child("messages").childByAutoId().updateChildValues(message.data) { _, ref in
                
                // 3. Add a conversation info into conversations table with message id
                let senderRef = Database.database().reference().child("conversations").child(tutorId).child(myUserType).child(partnerId)
                let receiverRef = Database.database().reference().child("conversations").child(partnerId).child(partnerType).child(tutorId)
                
                // Note: Do not update userSessions table because the applied service request should only show on messages and conversation screens.
                
                let messageId = ref.key!
                ref.updateChildValues(["uid": messageId])
                senderRef.updateChildValues([messageId: 1])
                receiverRef.updateChildValues([messageId: 1])
                
                // 4. Add a conversation meta data into conversationMetaData table
                var metaData = [String: Any]()
                metaData["lastUpdatedAt"] = message.timeStamp
                metaData["lastMessageSenderId"] = tutorId
                metaData["lastMessageContent"] = message.text ?? ""
                metaData["lastMessageProfilePicUrl"] = message.user?.profilePicUrl.absoluteString ?? ""
                metaData["lastMessageUsername"] = message.user?.username ?? ""
                metaData["lastMessageId"] = messageId
                metaData["memberIds"] = [tutorId, partnerId]
                
                Database.database().reference().child("conversationMetaData").child(tutorId).child(myUserType).child(partnerId).setValue(metaData)
                Database.database().reference().child("conversationMetaData").child(partnerId).child(partnerType).child(tutorId).setValue(metaData)
                
                // 5. Connect learner and tutor each other because they should communicate each other before accept a session of quickrequest
                let values = ["/\(tutorId)/\(myUserType)/\(partnerId)": 1, "/\(partnerId)/\(partnerType)/\(tutorId)": 1]
                Database.database().reference().child("connections").updateChildValues(values)
                
                // 6. Save tutorId, sessionId and quickRequestId into quickRequestsApplies table.
                Database.database().reference()
                    .child("quickRequestsApplies")
                    .child("tutor")
                    .child(tutorId).updateChildValues([request.id: 1], withCompletionBlock: { (error, ref) in
                        
                        Database.database().reference()
                            .child("quickRequestsApplies")
                            .child("quickRequest")
                            .child(request.id)
                            .childByAutoId()
                            .updateChildValues(["tutorId": tutorId, "sessionId": ref1.key!])
                        
                        NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.appliedToOpportunity, object: nil, userInfo: ["quickRequestId": request.id])
                    })
            }
        }
    }
    
    func getAppliedQuickRequestIds(completion: @escaping (([String]) -> Void)) {
        
        guard let tutorId = CurrentUser.shared.tutor.uid else {
            completion(appliedQuickRequestIds)
            return
        }
        
        if tutorQuickRequestsAppliesRefs == nil {
            tutorQuickRequestsAppliesRefs = []
        }
        
        if tutorQuickRequestsAppliesHandles == nil {
            tutorQuickRequestsAppliesHandles = []
        }
        
        if let tutorQuickRequestsAppliesRefs = tutorQuickRequestsAppliesRefs, let tutorQuickRequestsAppliesHandles = tutorQuickRequestsAppliesHandles {
            tutorQuickRequestsAppliesRefs.enumerated().forEach { (index, ref) in
                ref.removeObserver(withHandle: tutorQuickRequestsAppliesHandles[index])
            }
        }
        
        // Get the applied quickrequests, so user can not participate in a applied quickrequest again.
        let applyRef = Database.database().reference()
            .child("quickRequestsApplies")
            .child("tutor")
            .child(tutorId)
        
        applyRef.observeSingleEvent(of: .value) { (snapshot) in
            
            let applyHandle = applyRef.observe(.childAdded) { (snapshot) in
                if !snapshot.exists() {
                    return
                }
                
                if let children = snapshot.children.allObjects as? [DataSnapshot] {
                    let newIds = children.map({$0.key})
                    let filtered = newIds.filter({ (id) -> Bool in
                        return !self.appliedQuickRequestIds.contains(id)
                    })
                    if !filtered.isEmpty {
                        self.appliedQuickRequestIds.append(contentsOf: newIds)
                    }
                }
            }
            
            self.tutorQuickRequestsAppliesHandles?.append(applyHandle)
            
            if !snapshot.exists() {
                self.appliedQuickRequestIds.removeAll()
                completion(self.appliedQuickRequestIds)
                return
            }
            
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                let newIds = children.map({$0.key})
                let filtered = newIds.filter({ (id) -> Bool in
                    return !self.appliedQuickRequestIds.contains(id)
                })
                if !filtered.isEmpty {
                    self.appliedQuickRequestIds.append(contentsOf: newIds)
                }
                completion(self.appliedQuickRequestIds)
            }
        }
        
        tutorQuickRequestsAppliesRefs?.append(applyRef)
    }
    
    func getOpportunitiesBySubjects() {
        guard let subjects = CurrentUser.shared.tutor.subjects else {
            return
        }
        
        // Initialize handles and refs for quickRequestsSubjects
        if tutorQuickRequestsSubjectsRefs == nil {
            tutorQuickRequestsSubjectsRefs = []
        }
        if tutorQuickRequestsSubjectsHandles == nil {
            tutorQuickRequestsSubjectsHandles = []
        }
        if let tutorQuickRequestsSubjectsRefs = tutorQuickRequestsSubjectsRefs, let tutorQuickRequestsSubjectsHandles = tutorQuickRequestsSubjectsHandles {
            tutorQuickRequestsSubjectsRefs.enumerated().forEach { (index, ref) in
                ref.removeObserver(withHandle: tutorQuickRequestsSubjectsHandles[index])
            }
        }
        tutorQuickRequestsSubjectsRefs?.removeAll()
        tutorQuickRequestsSubjectsHandles?.removeAll()
        
        var emptySubjects = 0
        for subject in subjects {
            // Get a quickrequest from quickRequestsSubjects table with a subject as the search keyword.
            let ref = Database.database().reference().child("quickRequestsSubjects").child(subject.lowercased())
            ref.observeSingleEvent(of: .value) { (snapshot) in
                
                let handle = ref.observe(.childAdded) { (snapshot) in
                    if !snapshot.exists() {
                        return
                    }
                    
                    let id = snapshot.key
                    // Get the detail info of a quickrequest
                    Database.database().reference().child("quickRequests").child(id).observeSingleEvent(of: .value, with: { (requestSnapshot) in
                        if let dictionary = requestSnapshot.value as? [String: Any] {
                            let quickRequest = QTQuickRequestModel(data: dictionary)
                            
                            // Check the tutor has already applied this quickRequest or not.
                            if !self.appliedQuickRequestIds.contains(quickRequest.id) {
                                FirebaseData.manager.fetchLearner(quickRequest.senderId, { (learner) in
                                    quickRequest.profileImageUrl = learner?.profilePicUrl
                                    quickRequest.userName = learner?.formattedName
                                    
                                    NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.quickRequestAdded, object: nil, userInfo: ["quickRequest": quickRequest])
                                })
                            }
                            
                            return
                        }
                    })
                }
                
                self.tutorQuickRequestsSubjectsHandles?.append(handle)
                
                if !snapshot.exists() {
                    emptySubjects += 1
                    if emptySubjects == subjects.count {
                        NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.noQuickRequest, object: nil, userInfo: nil)
                    }
                    return
                }
                
                if let children = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in children {
                        Database.database().reference().child("quickRequests").child(child.key).observeSingleEvent(of: .value, with: { (requestSnapshot) in
                            if let dictionary = requestSnapshot.value as? [String: Any] {
                                let quickRequest = QTQuickRequestModel(data: dictionary)
                                
                                // Check the tutor has already applied this quickRequest or not.
                                if !self.appliedQuickRequestIds.contains(quickRequest.id) {
                                    FirebaseData.manager.fetchLearner(quickRequest.senderId, { (learner) in
                                        quickRequest.profileImageUrl = learner?.profilePicUrl
                                        quickRequest.userName = learner?.formattedName
                                        
                                        NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.quickRequestAdded, object: nil, userInfo: ["quickRequest": quickRequest])
                                    })
                                }
                                
                                return
                            }
                        })
                    }
                }
                
            }
            
            // Save the database reference and handle.
            tutorQuickRequestsSubjectsRefs?.append(ref)
        }
    }
    
    func getOpportunitiesBySubcategories() {
        
        guard let subjects = CurrentUser.shared.tutor.subjects else {
            return
        }
        
        var subcategoryNames = [String]()
        subjects.forEach { (subject) in
            if let name = CategoryFactory.shared.getSubcategoryFor(subject: subject)?.name {
                subcategoryNames.append(name)
            }
        }
        
        // Initialize handles and refs for quickRequestsSubcategories
        if tutorQuickRequestsSubcategoriesRefs == nil {
            tutorQuickRequestsSubcategoriesRefs = []
        }
        if tutorQuickRequestsSubcategoriesHandles == nil {
            tutorQuickRequestsSubjectsHandles = []
        }
        if let tutorQuickRequestsSubcategoriesRefs = tutorQuickRequestsSubcategoriesRefs, let tutorQuickRequestsSubcategoriesHandles = tutorQuickRequestsSubcategoriesHandles {
            tutorQuickRequestsSubcategoriesRefs.enumerated().forEach { (index, ref) in
                ref.removeObserver(withHandle: tutorQuickRequestsSubcategoriesHandles[index])
            }
        }
        tutorQuickRequestsSubcategoriesRefs?.removeAll()
        tutorQuickRequestsSubcategoriesHandles?.removeAll()
        
        var emptySubcategories = 0
        for name in subcategoryNames {
            // Get a quickrequest from quickRequestsSubcategories table with a subject as the search keyword.
            let ref = Database.database().reference().child("quickRequestSubcategories").child(name.lowercased())
            ref.observeSingleEvent(of: .value) { (snapshot) in
                
                let handle = ref.observe(.childAdded) { (snapshot) in
                    if !snapshot.exists() {
                        return
                    }
                    
                    let id = snapshot.key
                    // Get the detail info of a quickrequest
                    Database.database().reference().child("quickRequests").child(id).observeSingleEvent(of: .value, with: { (requestSnapshot) in
                        if let dictionary = requestSnapshot.value as? [String: Any] {
                            let quickRequest = QTQuickRequestModel(data: dictionary)
                            
                            // Check the tutor has already applied this quickRequest or not.
                            if !self.appliedQuickRequestIds.contains(quickRequest.id) {
                                FirebaseData.manager.fetchLearner(quickRequest.senderId, { (learner) in
                                    quickRequest.profileImageUrl = learner?.profilePicUrl
                                    quickRequest.userName = learner?.formattedName
                                    
                                    NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.quickRequestAdded, object: nil, userInfo: ["quickRequest": quickRequest])
                                })
                            }
                            
                            return
                        }
                    })
                }
                self.tutorQuickRequestsSubcategoriesHandles?.append(handle)
                
                if !snapshot.exists() {
                    emptySubcategories += 1
                    if emptySubcategories == subcategoryNames.count {
                        NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.noQuickRequest, object: nil, userInfo: nil)
                    }
                    return
                }
                
                if let children = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in children {
                        // Get the detail info of a quickrequest
                        Database.database().reference().child("quickRequests").child(child.key).observeSingleEvent(of: .value, with: { (requestSnapshot) in
                            if let dictionary = requestSnapshot.value as? [String: Any] {
                                let quickRequest = QTQuickRequestModel(data: dictionary)
                                
                                // Check the tutor has already applied this quickRequest or not.
                                if !self.appliedQuickRequestIds.contains(quickRequest.id) {
                                    FirebaseData.manager.fetchLearner(quickRequest.senderId, { (learner) in
                                        quickRequest.profileImageUrl = learner?.profilePicUrl
                                        quickRequest.userName = learner?.formattedName
                                        
                                        NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.quickRequestAdded, object: nil, userInfo: ["quickRequest": quickRequest])
                                    })
                                }
                                
                                return
                            }
                        })
                    }
                }
            }
            
            // Save the database reference and handle.
            tutorQuickRequestsSubcategoriesRefs?.append(ref)
        }
    }
    
    func getOpportunitiesByCategories() {
        guard let subjects = CurrentUser.shared.tutor.subjects else {
            return
        }
        
        var categoryNames = [String]()
        subjects.forEach { (subject) in
            if let name = CategoryFactory.shared.getSubcategoryFor(subject: subject)?.category {
                categoryNames.append(name)
            }
        }
        
        // Initialize handles and refs for quickRequestsSubcategories
        if tutorQuickRequestsCategoriesRefs == nil {
            tutorQuickRequestsCategoriesRefs = []
        }
        if tutorQuickRequestsCategoriesHandles == nil {
            tutorQuickRequestsCategoriesHandles = []
        }
        if let tutorQuickRequestsCategoriesRefs = tutorQuickRequestsCategoriesRefs, let tutorQuickRequestsCategoriesHandles = tutorQuickRequestsCategoriesHandles {
            tutorQuickRequestsCategoriesRefs.enumerated().forEach { (index, ref) in
                ref.removeObserver(withHandle: tutorQuickRequestsCategoriesHandles[index])
            }
        }
        tutorQuickRequestsCategoriesRefs?.removeAll()
        tutorQuickRequestsCategoriesHandles?.removeAll()
        
        var emptyCategories = 0
        for name in categoryNames {
            // Get a quickrequest from quickRequestsCategories table with a subject as the search keyword.
            let ref = Database.database().reference().child("quickRequestsCategories").child(name.lowercased())
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                
                let handle = ref.observe(.childAdded) { (snapshot) in
                    if !snapshot.exists() {
                        return
                    }
                    
                    let id = snapshot.key
                    // Get the detail info of a quickrequest
                    Database.database().reference().child("quickRequests").child(id).observeSingleEvent(of: .value, with: { (requestSnapshot) in
                        if let dictionary = requestSnapshot.value as? [String: Any] {
                            let quickRequest = QTQuickRequestModel(data: dictionary)
                            
                            // Check the tutor has already applied this quickRequest or not.
                            if !self.appliedQuickRequestIds.contains(quickRequest.id) {
                                FirebaseData.manager.fetchLearner(quickRequest.senderId, { (learner) in
                                    quickRequest.profileImageUrl = learner?.profilePicUrl
                                    quickRequest.userName = learner?.formattedName
                                    
                                    NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.quickRequestAdded, object: nil, userInfo: ["quickRequest": quickRequest])
                                })
                            }
                            
                            return
                        }
                    })
                }
                self.tutorQuickRequestsCategoriesHandles?.append(handle)
                
                if !snapshot.exists() {
                    emptyCategories += 1
                    if emptyCategories == categoryNames.count {
                        NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.noQuickRequest, object: nil, userInfo: nil)
                    }
                    return
                }
                
                if let children = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in children {
                        // Get the detail info of a quickrequest
                        Database.database().reference().child("quickRequests").child(child.key).observeSingleEvent(of: .value, with: { (requestSnapshot) in
                            if let dictionary = requestSnapshot.value as? [String: Any] {
                                let quickRequest = QTQuickRequestModel(data: dictionary)
                                
                                // Check the tutor has already applied this quickRequest or not.
                                if !self.appliedQuickRequestIds.contains(quickRequest.id) {
                                    FirebaseData.manager.fetchLearner(quickRequest.senderId, { (learner) in
                                        quickRequest.profileImageUrl = learner?.profilePicUrl
                                        quickRequest.userName = learner?.formattedName
                                        
                                        NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.quickRequestAdded, object: nil, userInfo: ["quickRequest": quickRequest])
                                    })
                                }
                                
                                return
                            }
                        })
                    }
                }
            }
            
            
            // Save the database reference and handle.
            tutorQuickRequestsCategoriesRefs?.append(ref)
        }
    }
    
    func getRemovedOpportunities() {
        // Get removed quick requests
        let ref = Database.database().reference()
            .child("quickRequestsApplies")
            .child("quickRequest")
            
        let handle = ref.observe(.childRemoved) { (snapshot) in
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                let ids = children.map({$0.key})
                NotificationCenter.default.post(name: NotificationNames.TutorDiscoverPage.quickRequestRemoved, object: nil, userInfo: ["quickRequestIds": ids])
            }
        }
        
        tutorQuickRequestsAppliesRefs?.append(ref)
        tutorQuickRequestsAppliesHandles?.append(handle)
    }
    
    func getOpportunities() {
        
        let group = DispatchGroup()
        group.enter()
        getAppliedQuickRequestIds { (_) in
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.getOpportunitiesBySubjects()
            self.getOpportunitiesBySubcategories()
            self.getOpportunitiesByCategories()
            self.getRemovedOpportunities()
        }
    }
    
    func removeOpportunityObservers() {
        if let refs = tutorQuickRequestsSubjectsRefs, let handles = tutorQuickRequestsSubjectsHandles {
            refs.enumerated().forEach { (index, ref) in
                ref.removeObserver(withHandle: handles[index])
            }
        }
        tutorQuickRequestsSubjectsRefs?.removeAll()
        tutorQuickRequestsSubjectsHandles?.removeAll()
        
        
        if let refs = tutorQuickRequestsSubcategoriesRefs, let handles = tutorQuickRequestsSubcategoriesHandles {
            refs.enumerated().forEach { (index, ref) in
                ref.removeObserver(withHandle: handles[index])
            }
        }
        tutorQuickRequestsSubcategoriesRefs?.removeAll()
        tutorQuickRequestsSubcategoriesHandles?.removeAll()
        
        if let refs = tutorQuickRequestsCategoriesRefs, let handles = tutorQuickRequestsCategoriesHandles {
            refs.enumerated().forEach { (index, ref) in
                ref.removeObserver(withHandle: handles[index])
            }
        }
        tutorQuickRequestsCategoriesRefs?.removeAll()
        tutorQuickRequestsCategoriesHandles?.removeAll()
    }
}
