//
//  DatabaseCleaner.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/12/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

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
    
    func setFeaturedSubjectNow() {
        let dict = ["subject": "Cooking", "imgUrl": "https://firebasestorage.googleapis.com/v0/b/quicktutor-3c23b.appspot.com/o/adult-blond-board-298926.jpg?alt=media&token=316575cc-debf-4e9b-9cee-c50e1faa514e"]
        Database.database().reference().child("featuredSubjects").childByAutoId().setValue(dict)
    }
    
    private init() {}
}
