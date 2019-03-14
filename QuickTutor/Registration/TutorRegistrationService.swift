//
//  TutorRegistrationService.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class TutorRegistrationService {
    static let shared = TutorRegistrationService()
    var shouldSaveSubjects = true
    
    var subjects = [String]()
    
    func addSubject(_ subject: String) {
        if shouldSaveSubjects {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference().child("subjects").child(subject).child(uid).setValue(1)
            Database.database().reference().child("tutor-info").child(uid).child("subjects").child(subject).setValue(1)
            guard let subcategory = CategoryFactory.shared.getSubcategoryFor(subject: subject) else { return }
            if !subcategoriesTaught().contains(where: {$0.name == subcategory.name}) {
                print("Adding to subcategory:", subcategory.name)
                Database.database().reference().child("subcategories").child(subcategory.name.lowercased()).child(uid).setValue(1)
            }
            if !categoriesTaught().contains(where: {$0.name == subcategory.category}) {
                print("Adding to category:", subcategory.category)
                Database.database().reference().child("categories").child(subcategory.category).child(uid).setValue(1)
            }
        }
        subjects.append(subject)
        NotificationCenter.default.post(name: Notifications.tutorSubjectsDidChange.name, object: nil, userInfo: nil)
    }
    
    
    func removeSubject(_ subject: String) {
        subjects = subjects.filter({ $0 != subject})
        NotificationCenter.default.post(name: Notifications.tutorSubjectsDidChange.name, object: nil, userInfo: nil)
        if shouldSaveSubjects {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference().child("subjects").child(subject).child(uid).removeValue()
            Database.database().reference().child("tutor-info").child(uid).child("subjects").child(subject).removeValue()
            guard let subcategory = CategoryFactory.shared.getSubcategoryFor(subject: subject) else { return }
            if !subcategoriesTaught().contains(where: {$0.name == subcategory.name}) {
                print("Removing from subcategory:", subcategory.name)
                Database.database().reference().child("subcategories").child(subcategory.name.lowercased()).child(uid).removeValue()
            }
            if !categoriesTaught().contains(where: {$0.name == subcategory.category}) {
                print("Removing from category:", subcategory.category)
                Database.database().reference().child("categories").child(subcategory.category).child(uid).removeValue()
            }
        }
    }
    
    func setFeaturedSubject(_ subject: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("tutor-info").child(uid).child("sbj").setValue(subject)
        
    }
    
    func categoriesTaught() -> [CategoryNew] {
        var categories = [CategoryNew]()
        subjects.forEach { (subject) in
            if let category = CategoryFactory.shared.getCategoryFor(subject: subject) {
                guard !categories.contains(where: {$0.name == category.name}) else { return }
                categories.append(category)
            }
        }
        return categories
    }
    
    func subcategoriesTaught() -> [SubcategoryNew] {
        var subcategories = [SubcategoryNew]()
        subjects.forEach { (subject) in
            if let subcategory = CategoryFactory.shared.getSubcategoryFor(subject: subject) {
                guard !subcategories.contains(where: {$0.name == subcategory.name}) else { return }
                subcategories.append(subcategory)
            }
        }
        return subcategories
    }
    
    private init() {
        if CurrentUser.shared.learner.isTutor {
            subjects = CurrentUser.shared.tutor.subjects ?? [String]()
        } else {
            subjects = [String]()
        }
    }
}
