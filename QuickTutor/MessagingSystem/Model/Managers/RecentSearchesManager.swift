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
            self.searches = searches.keys.map({$0})
        }
    }
    
    func saveSearch(term searchTerm: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard !searches.contains(searchTerm) else { return }
        Database.database().reference().child("searches").child(uid).child(searchTerm).setValue(1)
        searches.append(searchTerm)
    }
    
    private init() {
        fetchSearches()
    }
    
}
