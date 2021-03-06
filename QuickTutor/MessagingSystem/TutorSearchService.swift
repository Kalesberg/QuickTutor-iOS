//
//  TutorSearchService.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/12/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

class TutorSearchService {
    static let shared = TutorSearchService()
    
    func getTutorsByCategory(_ categoryName: String, lastKnownKey: String?, queue: DispatchQueue = .main, completion: @escaping ([AWTutor]?, Bool) -> Void) {
        var tutors = [AWTutor]()
        let myGroup = DispatchGroup()
        var ref = Database.database().reference().child("categories").child(categoryName).queryOrderedByKey()
        if let key = lastKnownKey {
            ref = ref.queryStarting(atValue: key)
        }
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let tutorIds = snapshot.value as? [String: Any] else {
                completion(nil, false)
                return
            }
            
            tutorIds.keys.sorted(by: { $0 < $1 }).forEach { uid in
                myGroup.enter()
                FirebaseData.manager.fetchTutor(uid, isQuery: false, queue: .global()) { tutor in
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
                }
            }
            myGroup.notify(queue: queue) {
                if let _ = lastKnownKey {
                    tutors.removeFirst()
                }
                completion(tutors, false)
            }
        }
    }
    
    func getTutorsBySubcategory(_ subcategoryName: String, lastKnownKey: String?, queue: DispatchQueue = .main, completion: @escaping ([AWTutor]?, Bool) -> Void) {
        var tutors = [AWTutor]()
        let desiredSubjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: subcategoryName)
        
        var ref = Database.database().reference().child("subcategories").child(subcategoryName.lowercased()).queryOrderedByKey()
        if let key = lastKnownKey {
            ref = ref.queryStarting(atValue: key)
        }
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let tutorIds = snapshot.value as? [String: Any] else {
                completion(nil, false)
                return
            }
            let myGroup = DispatchGroup()
            tutorIds.keys.sorted(by: { $0 < $1 }).forEach { uid in
                myGroup.enter()
                FirebaseData.manager.fetchTutor(uid, isQuery: false, queue: .global()) { tutor in
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
                }
            }
            myGroup.notify(queue: queue) {
                if let _ = lastKnownKey {
                    tutors.removeFirst()
                }
                completion(tutors, false)
            }
        }
    }
    
    func getTutorsBySubject(_ subject: String, lastKnownKey: String?, queue: DispatchQueue = .main, completion: @escaping ([AWTutor]?, Bool) -> Void) {
        var tutors = [AWTutor]()
        var ref = Database.database().reference().child("subjects").child(subject).queryOrderedByKey()
        
        if let key = lastKnownKey {
            ref = ref.queryStarting(atValue: key)
        }
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let tutorIds = snapshot.value as? [String: Any] else {
                completion(nil, false)
                return
                
            }
            let myGroup = DispatchGroup()
            tutorIds.keys.sorted(by: { $0 < $1 }).forEach { uid in
                myGroup.enter()
                FirebaseData.manager.fetchTutor(uid, isQuery: false, queue: queue) { tutor in
                    guard let tutor = tutor else {
                        myGroup.leave()
                        return
                    }
                    tutor.featuredSubject = subject
                    if tutor.uid != Auth.auth().currentUser?.uid {
                        tutors.append(tutor)
                    }
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: queue) {
                if let _ = lastKnownKey {
                    tutors.removeFirst()
                }
                completion(tutors, false)
            }
        }
    }
    
    func getTutorIdsBySubject(_ subject: String, completion: @escaping ([String]?) -> Void) {
        Database.database().reference().child("subjects").child(subject).queryOrderedByKey().observeSingleEvent(of: .value) { snapshot in
            guard let dicTutorIds = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            var aryTutorIds: [String] = []
            dicTutorIds.keys.forEach { tutorId in
                aryTutorIds.append(tutorId)
            }
            completion(aryTutorIds)
        }
    }
    
    func getTutorIdsBySubcategory(_ subcategory: String, completion: @escaping ([String]?) -> Void) {
        Database.database().reference().child("subcategories").child(subcategory.lowercased()).queryOrderedByKey().observeSingleEvent(of: .value) { snapshot in
            guard let dicTutorIds = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            var aryTutorIds: [String] = []
            dicTutorIds.keys.forEach { tutorId in
                aryTutorIds.append(tutorId)
            }
            completion(aryTutorIds)
        }
    }
    
    func getTutorIdsByCategory(_ category: String, completion: @escaping ([String]?) -> Void) {
        Database.database().reference().child("categories").child(category).queryOrderedByKey().observeSingleEvent(of: .value) { snapshot in
            guard let dicTutorIds = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            var aryTutorIds: [String] = []
            dicTutorIds.keys.forEach { tutorId in
                aryTutorIds.append(tutorId)
            }
            completion(aryTutorIds)
        }
    }
    
    func getTopTutors(completion: @escaping([AWTutor]) -> Void) {
        Database.database().reference().child("tutor-info").queryOrdered(byChild: "nos").observeSingleEvent(of: .value) { (snapshot) in
            guard let tutorsDict = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
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
            
            group.notify(queue: .main) {
                completion(tutors.sorted(by: {$0.tNumSessions > $1.tNumSessions}))
            }
        }
    }
    
    func getNewRecommentedTutors(completion: @escaping ([AWTutor]) -> Void) {
        
        var tutors = [AWTutor]()
        
        let concurrentQueue = DispatchQueue(label: QTDispatchQueueName.getNewRecommentedTutors, attributes: .concurrent)

        guard AccountService.shared.currentUserType == .learner, let uid = Auth.auth().currentUser?.uid else {
            completion(tutors)
            return
        }
        let group = DispatchGroup()
        // Get connections
        let userTypeString = AccountService.shared.currentUserType.rawValue
        group.enter()
        Database.database().reference().child("connections").child(uid).child(userTypeString).observeSingleEvent(of: .value) { snapshot in
            guard let connections = snapshot.value as? [String: Any] else {
                group.leave()
                return
            }
            
            connections.keys.forEach { key in
                group.enter()
                UserFetchService.shared.getTutorWithId(uid: key
                    , completion: { (tutor) in
                        if let tutor = tutor {
//                            tutors.append(tutor)
                            concurrentQueue.async(flags: .barrier) { [weak self] in
                                if self != nil {
                                    tutors.append(tutor)
                                }
                                group.leave()
                            }
                        } else {
                            group.leave()
                        }
                })
            }
            group.leave()
        }
        
        // Get recent searches and tapped users.
        let recentSearches = QTUtils.shared.getRecentTutors()
        if !recentSearches.isEmpty {
            recentSearches.compactMap({$0.uid}).forEach { (uid) in
                group.enter()
                FirebaseData.manager.fetchTutor(uid, isQuery: false, { tutor in
                    guard let tutor = tutor else {
                        group.leave()
                        return
                    }
                    
                    if tutor.uid != Auth.auth().currentUser?.uid {
//                        tutors.append(tutor)
                        concurrentQueue.async(flags: .barrier) { [weak self] in
                            if self != nil {
                                tutors.append(tutor)
                            }
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                })
            }
        }
        
        // Interestes
        if let interests = CurrentUser.shared.learner.interests {
            interests.forEach { (subject) in
                group.enter()
                self.getTutorsBySubject(subject, lastKnownKey: nil, completion: { (sessionTutors, _) in
                    guard let sessionTutors = sessionTutors else {
                        group.leave()
                        return
                    }
                    
                    concurrentQueue.async(flags: .barrier) { [weak self] in
                        if self != nil {
                            tutors += sessionTutors
                        }
                        group.leave()
                    }
//                    tutors += sessionTutors
//                    group.leave()
                })
            }
        }
        
        group.notify(queue: .main, execute: {
            completion(tutors)
        })
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
    
    func fetchLearnerRisingTalents(category: String? = nil, subcategory: String? = nil, completion: @escaping ([AWTutor]) -> Void) {
        
        var accountIds: [String] = []
        let lastCreateTime = Date().timeIntervalSince1970 - 60 * 24 * 3600
        Database.database().reference().child("account").queryOrdered(byChild: "init").queryStarting(atValue: lastCreateTime).observeSingleEvent(of: .value) { snapshot in
            guard let dicAccounts = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            accountIds.append(contentsOf: dicAccounts.keys)
            let lastActiveTime = Date().timeIntervalSince1970 - 90 * 24 * 3600
            Database.database().reference().child("account").queryOrdered(byChild: "online").queryStarting(atValue: lastActiveTime).observeSingleEvent(of: .value) { snapshot in
                guard let dicAccounts = snapshot.value as? [String: Any] else {
                    completion([])
                    return
                }
                dicAccounts.keys.forEach { accountId in
                    if !accountIds.contains(accountId) {
                        accountIds.append(accountId)
                    }
                }
                
                let accountIdsGroup = DispatchGroup()
                if let category = category {
                    accountIdsGroup.enter()
                    TutorSearchService.shared.getTutorIdsByCategory(category) { tutorIds in
                        accountIds = accountIds.filter({ true == tutorIds?.contains($0) })
                        accountIdsGroup.leave()
                    }
                } else if let subcategory = subcategory {
                    accountIdsGroup.enter()
                    TutorSearchService.shared.getTutorIdsBySubcategory(subcategory) { tutorIds in
                        accountIds = accountIds.filter({ true == tutorIds?.contains($0) })
                        accountIdsGroup.leave()
                    }
                } else {
                    accountIdsGroup.enter()
                    Database.database().reference().child("tutor-info").queryOrderedByKey().observeSingleEvent(of: .value) { snapshot in
                        if let dicTutors = snapshot.value as? [String: Any] {
                            accountIds = accountIds.filter({ dicTutors.keys.contains($0) })
                        } else {
                            accountIds = []
                        }
                        accountIdsGroup.leave()
                    }
                }
                accountIdsGroup.notify(queue: .global()) {
                    var aryTutors: [AWTutor] = []
                    let tutorsGroup = DispatchGroup()
                    for accountId in accountIds {
                        if accountId == Auth.auth().currentUser?.uid { continue }
                        
                        tutorsGroup.enter()
                        FirebaseData.manager.fetchTutor(accountId, isQuery: false, queue: .global()) { tutor in
                            if let tutor = tutor {
                                if let category = category {
                                    tutor.featuredSubject = tutor.subjects?.first(where: { (subject) -> Bool in
                                        let subjectCategory = CategoryFactory.shared.getCategoryFor(subject: subject)
                                        return subjectCategory?.name == category
                                    })
                                } else if let subcategory = subcategory {
                                    tutor.featuredSubject = tutor.subjects?.first(where: { (subject) -> Bool in
                                        let desiredSubjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: subcategory)
                                        return desiredSubjects?.contains(subject) ?? false
                                    })
                                }
                                aryTutors.append(tutor)
                            }
                            tutorsGroup.leave()
                        }
                    }
                    
                    tutorsGroup.notify(queue: .main) {
                        completion(self.sortTutors(tutors: aryTutors, category: category, subcategory: subcategory))
                    }
                }
            }
        }
    }
    
    func sortTutors(tutors: [AWTutor], category: String?, subcategory: String?) -> [AWTutor] {
        return tutors.sorted() { tutor1, tutor2 -> Bool in
            if let category = category {
                let categoryReviews1 = tutor1.categoryReviews(category).count
                let categoryReviews2 = tutor2.categoryReviews(category).count
                return categoryReviews1 > categoryReviews2
                    || (categoryReviews1 == categoryReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                    || (categoryReviews1 == categoryReviews2 && tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            } else if let subcategory = subcategory {
                let subcategoryReviews1 = tutor1.reviews?.filter({ subcategory == SubjectStore.shared.findSubCategory(subject: $0.subject) }).count ?? 0
                let subcategoryReviews2 = tutor2.reviews?.filter({ subcategory == SubjectStore.shared.findSubCategory(subject: $0.subject) }).count ?? 0
                return subcategoryReviews1 > subcategoryReviews2
                    || (subcategoryReviews1 == subcategoryReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                    || (subcategoryReviews1 == subcategoryReviews2 && tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            } else {
                return (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0)
                    || (tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            }
        }
    }
    
    func fetchRecentlyActiveTutors(category: String? = nil, subcategory: String? = nil, limit: Int = 3000, completion: @escaping ([AWTutor]) -> Void) {
        let lastActiveTime = Date().timeIntervalSince1970 - 72 * 3600
        Database.database().reference().child("account").queryOrdered(byChild: "online").queryStarting(atValue: lastActiveTime).observeSingleEvent(of: .value) { snapshot in
            guard let dicAccount = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            var accountIds = Array(dicAccount.keys)
            
            let accountIdsGroup = DispatchGroup()
            if let category = category {
                accountIdsGroup.enter()
                TutorSearchService.shared.getTutorIdsByCategory(category) { tutorIds in
                    accountIds = accountIds.filter({ true == tutorIds?.contains($0) })
                    accountIdsGroup.leave()
                }
            } else if let subcategory = subcategory {
                accountIdsGroup.enter()
                TutorSearchService.shared.getTutorIdsBySubcategory(subcategory) { tutorIds in
                    accountIds = accountIds.filter({ true == tutorIds?.contains($0) })
                    accountIdsGroup.leave()
                }
            }
            accountIdsGroup.notify(queue: .global()) {
                var aryTutors: [AWTutor] = []
                let tutorsGroup = DispatchGroup()
                for accountId in accountIds.prefix(limit) {
                    if accountId == Auth.auth().currentUser?.uid { continue }
                    
                    tutorsGroup.enter()
                    FirebaseData.manager.fetchTutor(accountId, isQuery: false, queue: .global()) { tutor in
                        if let tutor = tutor {
                            aryTutors.append(tutor)
                        }
                        tutorsGroup.leave()
                    }
                }
                
                tutorsGroup.notify(queue: .main) {
                    completion(aryTutors)
                }
            }
        }
    }
    
    func loadRandongTutorIds(category: String? = nil, subcategory: String? = nil, queue: DispatchQueue = .main, completion: @escaping ([String]) -> Void) {
        var aryTutorIds: [String] = []
        let tutorIdsGroup = DispatchGroup()
        if let category = category {
            tutorIdsGroup.enter()
            TutorSearchService.shared.getTutorIdsByCategory(category) { tutorIds in
                if let tutorIds = tutorIds {
                    aryTutorIds = tutorIds
                }
                tutorIdsGroup.leave()
            }
        } else if let subcategory = subcategory {
            tutorIdsGroup.enter()
            TutorSearchService.shared.getTutorIdsBySubcategory(subcategory) { tutorIds in
                if let tutorIds = tutorIds {
                    aryTutorIds = tutorIds
                }
                tutorIdsGroup.leave()
            }
        } else {
            tutorIdsGroup.enter()
            Database.database().reference().child("tutor-info").queryOrderedByKey().observeSingleEvent(of: .value) { snapshot in
                guard let dicAccount = snapshot.value as? [String: Any] else {
                    tutorIdsGroup.leave()
                    return
                }
                
                aryTutorIds = Array(dicAccount.keys)
                tutorIdsGroup.leave()
            }
        }
        tutorIdsGroup.notify(queue: queue) {
            completion(aryTutorIds)
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
