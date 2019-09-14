//
//  LearnerRegistrationService.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class LearnerRegistrationService {

    static let shared = LearnerRegistrationService()
    var interests = [String]()
    
    var shouldSaveInterests = true
    
    func addInterest(_ subject: String) {
        guard !interests.contains(subject) else { return }
        guard interests.count <= 12 else {
            // TODO: change notification name
            NotificationCenter.default.post(name: Notifications.learnerTooManyInterests.name, object: nil)
            return
        }
        
        if shouldSaveInterests {
            guard let uid = CurrentUser.shared.learner.uid else { return }
            
            var newValue = [
                "name": CurrentUser.shared.learner.formattedName,
                "email": CurrentUser.shared.learner.email
            ]
            if let phone = CurrentUser.shared.learner.phone,
                !phone.isEmpty {
                newValue["phone"] = phone
            }
            
            Database.database().reference().child("interests").child(subject).child(uid).setValue(newValue)
            Database.database().reference().child("student-info").child(uid).child("interests").child(subject).setValue(1)
            guard let subcategory = CategoryFactory.shared.getSubcategoryFor(subject: subject) else { return }
            if !subcategoriesTaught().contains(where: {$0.name == subcategory.name}) {
                print("Adding interest to subcategory:", subcategory.name)
                Database.database().reference().child("interest-subcategories").child(subcategory.name.lowercased()).child(uid).setValue(newValue)
            }
            if !categoriesTaught().contains(where: {$0.name == subcategory.category}) {
                print("Adding interest to category:", subcategory.category)
                Database.database().reference().child("interest-categories").child(subcategory.category).child(uid).setValue(newValue)
            }
        }
        interests.append(subject)
        // Save current interests again to the current learner account
        CurrentUser.shared.learner.interests = interests
        NotificationCenter.default.post(name: Notifications.learnerDidAddInterest.name, object: nil, userInfo: nil)
    }
    
    
    func removeInterest(_ subject: String) {
        interests = interests.filter({ $0 != subject})
        
        NotificationCenter.default.post(name: Notifications.learnerDidRemoveInterest.name, object: nil, userInfo: nil)
        if shouldSaveInterests {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference().child("interests").child(subject).child(uid).removeValue()
            Database.database().reference().child("student-info").child(uid).child("interests").child(subject).removeValue()
            guard let subcategory = CategoryFactory.shared.getSubcategoryFor(subject: subject) else { return }
            if !subcategoriesTaught().contains(where: {$0.name == subcategory.name}) {
                print("Removing from subcategory:", subcategory.name)
                Database.database().reference().child("interest-subcategories").child(subcategory.name.lowercased()).child(uid).removeValue()
            }
            if !categoriesTaught().contains(where: {$0.name == subcategory.category}) {
                print("Removing from category:", subcategory.category)
                Database.database().reference().child("interest-categories").child(subcategory.category).child(uid).removeValue()
            }
            
            // Save current interests again to the current learner account
            CurrentUser.shared.learner.interests = interests
        }
    }
    
    func categoriesTaught() -> [CategoryNew] {
        var categories = [CategoryNew]()
        interests.forEach { (subject) in
            if let category = CategoryFactory.shared.getCategoryFor(subject: subject) {
                guard !categories.contains(where: {$0.name == category.name}) else { return }
                categories.append(category)
            }
        }
        return categories
    }
    
    func subcategoriesTaught() -> [SubcategoryNew] {
        var subcategories = [SubcategoryNew]()
        interests.forEach { (subject) in
            if let subcategory = CategoryFactory.shared.getSubcategoryFor(subject: subject) {
                guard !subcategories.contains(where: {$0.name == subcategory.name}) else { return }
                subcategories.append(subcategory)
            }
        }
        return subcategories
    }
    
    private init() {
        if AccountService.shared.currentUserType == .learner {
            interests = CurrentUser.shared.learner.interests ?? []
        } else {
            interests = []
        }
    }
}
