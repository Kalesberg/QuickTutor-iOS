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
    
    func getTutorsByCategory(_ categoryName: String, lastKnownKey: String?, completion: @escaping ([AWTutor]?, Bool) -> Void) {
        var tutors = [AWTutor]()
        let myGroup = DispatchGroup()
        var ref = Database.database().reference().child("categories").child(categoryName).queryOrderedByKey().queryLimited(toFirst: 60)
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
            }
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
        ref.observeSingleEvent(of: .value) { (snapshot) in
            print("=== Get subcategories ids === ")
            print(Date().description)
            guard let tutorIds = snapshot.value as? [String: Any] else {
                completion(nil, false)
                return
            }
            let myGroup = DispatchGroup()
            tutorIds.keys.sorted(by: { $0 < $1 }).forEach { uid in
                myGroup.enter()
                
                print("=== Fetch \(uid) tutor Start === ")
                print(Date().description)
                
                FirebaseData.manager.fetchTutor(uid, isQuery: false, { tutor in
                    print("=== Fetch \(tutor?.uid ?? "blank") tutor End === ")
                    print(Date().description)
                    
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
            }
            myGroup.notify(queue: .main) {
                print("=== Fetch all tutor info === ")
                print(Date().description)
                
                if let _ = lastKnownKey {
                    tutors.removeFirst()
                }
                completion(tutors, tutorIds.count < 60)
            }
        }
    }
    
    func getTutorsBySubject(_ subject: String, lastKnownKey: String?, completion: @escaping ([AWTutor]?, Bool) -> Void) {
        var tutors = [AWTutor]()
        let myGroup = DispatchGroup()
        var ref = Database.database().reference().child("subjects").child(subject).queryOrderedByKey().queryLimited(toFirst: 60)
        
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
            }
            myGroup.notify(queue: .main) {
                if let _ = lastKnownKey {
                    tutors.removeFirst()
                }
                completion(tutors, tutorIds.count < 60)
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
    
    func getNewRecommentedTutors(completion: @escaping ([AWTutor]) -> Void) {
        
        var tutors = [AWTutor]()
        
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
                if key.compare(uid) != .orderedSame {
                    group.enter()
                    UserFetchService.shared.getTutorWithId(uid: key
                        , completion: { (tutor) in
                            if let tutor = tutor {
                                tutors.append(tutor)
                            }
                            group.leave()
                    })
                }
            }
            group.leave()
        }
        
        // Get recent searches and tapped users.
        let recentSearches = QTUtils.shared.getRecentTutors()
        if !recentSearches.isEmpty {
            recentSearches.compactMap({$0.uid}).forEach { (userId) in
                if userId.compare(uid) != .orderedSame {
                    group.enter()
                    FirebaseData.manager.fetchTutor(userId, isQuery: false, { tutor in
                        guard let tutor = tutor else {
                            group.leave()
                            return
                        }
                        tutors.append(tutor)
                        group.leave()
                    })
                }
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
                    tutors += sessionTutors
                    
                    // Remove the tutor profile of the current user.
                    if let index = tutors.firstIndex(where: {$0.uid.compare(uid) == .orderedSame}) {
                        tutors.remove(at: index)
                    }
                    
                    group.leave()
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
    
    func getCurrentlyOnlineTutors(completion: @escaping ([AWTutor]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("userStatus").queryOrdered(byChild: "status").queryEqual(toValue: 2).observeSingleEvent(of: .value) { (snapshot) in
            guard let uids = snapshot.value as? [String: Any] else { return }
            var tutors = [AWTutor]()
            let group = DispatchGroup()
            uids.forEach({ (key,value) in
                group.enter()
                FirebaseData.manager.fetchTutor(key, isQuery: false, { (tutor) in
                    guard let tutor = tutor, tutor.uid.compare(uid) != .orderedSame else {
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
