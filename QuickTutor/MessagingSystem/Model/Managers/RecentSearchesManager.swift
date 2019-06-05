//
//  RecentSearchesManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/13/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

class RecentSearchesManager {

    static let shared = RecentSearchesManager()

    private let MAX_LIMIT = 3
    
    var searches: [String] = [] {
        didSet {
            NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.searchesLoaded, object: nil)
        }
    }
    
    var hasNoRecentSearches: Bool {
        return searches.isEmpty
    }
    
    private func fetchSearches() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("searches").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let searches = snapshot.value as? [String: Any] else {
                self.searches = []
                return
            }
            self.searches = searches.keys.map({$0}).suffix(self.MAX_LIMIT)
        }
    }
    
    func saveSearch(term searchTerm: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard !searches.contains(searchTerm) else { return }
        searches.append(searchTerm)
        searches = searches.suffix(MAX_LIMIT)
        
        var updateValue: [String: Any] = [:]
        searches.forEach { term in
            updateValue[term] = true
        }
        Database.database().reference().child("searches").child(uid).updateChildValues(updateValue)
    }
    
    func removeSearch(item at: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let term = searches[at]
        Database.database().reference().child("searches").child(uid).child(term).removeValue()
        searches.remove(at: at)
        searches = searches.suffix(MAX_LIMIT)
    }
    
    private init() {
        fetchSearches()
    }
    
}
