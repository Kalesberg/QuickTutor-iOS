//
//  UserFetchService.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/12/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

class UserFetchService {
    
    static let shared = UserFetchService()
    private init() {}
    
    typealias TutorCompletion = (ZFTutor?) -> Void
    
    func getUserWithId(_ uid: String, type: UserType, completion: @escaping (ZFTutor?) -> Void) {
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
    
    func getUserOfOppositeTypeWithId(_ uid: String, completion: @escaping (ZFTutor?) -> Void) {
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
    
    /**
     Get a tutor info
     
     NOTE: DO NOT use this api if you want to get a full tutor info.
     */
    func getTutorWithId(_ uid: String, completion: @escaping TutorCompletion) {
        Database.database().reference().child("account").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            Database.database().reference().child("tutor-info").child(uid).observeSingleEvent(of: .value, with: { snapshot2 in
                guard let value2 = snapshot2.value as? [String: Any] else {
                    completion(nil)
                    return
                }
                let finalDict = self.mergeUserDictionaries(value, value2)
                guard let tutor = self.createUserFromDictionary(finalDict, withUid: uid) else {
                    completion(nil)
                    return
                }
                completion(tutor)
            })
        }
    }
    
    /**
     Get a learner info
     
     NOTE: DO NOT use this api if you want to a get full learner info.
     */
    func getStudentWithId(_ uid: String, completion: @escaping TutorCompletion) {
        Database.database().reference().child("account").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            Database.database().reference().child("student-info").child(uid).observeSingleEvent(of: .value, with: { snapshot2 in
                guard let value2 = snapshot2.value as? [String: Any] else {
                    completion(nil)
                    return
                }
                let finalDict = self.mergeUserDictionaries(value, value2)
                
                guard let tutor = self.createUserFromDictionary(finalDict, withUid: uid) else {
                    completion(nil)
                    return
                }
                completion(tutor)
            })
        }
    }
    
    private func mergeUserDictionaries(_ accountData: [String: Any], _ supplementaryData: [String: Any]) -> [String: Any] {
        return accountData.merging(supplementaryData, uniquingKeysWith: { (_, dict2Value) -> Any in
            dict2Value
        })
    }
    
    private func createUserFromDictionary(_ dictionary: [String: Any], withUid uid: String) -> ZFTutor? {
        let tutor = ZFTutor(dictionary: dictionary)
        tutor.uid = uid
        guard let img = dictionary["img"] as? [String: Any],
            img.keys.contains("image1"),
            let profilePicUrl = img["image1"] as? String else {
                tutor.profilePicUrl = Constants.AVATAR_PLACEHOLDER_URL
                return nil
        }
        tutor.profilePicUrl = URL(string: profilePicUrl)
        tutor.username = dictionary["nm"] as? String
        return tutor
    }
    
    
    /**
     Get a full tutor info
     
     NOTE: DO use this api if you want to get a full tutor info.
     */
    func getTutorWithId(uid: String, completion: @escaping (AWTutor?) -> Void) {
        Database.database().reference().child("account").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            Database.database().reference().child("tutor-info").child(uid).observeSingleEvent(of: .value, with: { snapshot2 in
                guard let value2 = snapshot2.value as? [String: Any] else { return }
                let finalDict = self.mergeUserDictionaries(value, value2)
                
                let tutor = AWTutor(dictionary: finalDict)
                tutor.uid = uid
                completion(tutor)
            })
        }
    }
    
    /**
     Get a full learner info
     
     NOTE: DO use this api if you want to get a full learner info.
     */
    func getStudentWithId(uid: String, completion: @escaping (AWLearner?) -> Void) {
        Database.database().reference().child("account").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            Database.database().reference().child("student-info").child(uid).observeSingleEvent(of: .value, with: { snapshot2 in
                guard let value2 = snapshot2.value as? [String: Any] else {
                    completion(nil)
                    return
                }
                let finalDict = self.mergeUserDictionaries(value, value2)
                let learner = AWLearner(dictionary: finalDict)
                learner.uid = uid
                completion(learner)
            })
        }
    }
    
}
