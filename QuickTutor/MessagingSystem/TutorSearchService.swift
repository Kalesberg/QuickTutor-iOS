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
                        completion(nil, false)
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
            print(snapshot.key)
            guard let tutorIds = snapshot.value as? [String: Any] else {
                completion(nil, false)
                return
            }
            let myGroup = DispatchGroup()
            tutorIds.keys.sorted(by: { $0 < $1 }).forEach { uid in
                myGroup.enter()
                FirebaseData.manager.fetchTutor(uid, isQuery: false, { tutor in
                    guard let tutor = tutor else {
                        myGroup.leave()
                        completion(nil, false)
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
                        completion(nil, false)
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
