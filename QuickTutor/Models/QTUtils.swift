//
//  QTUtils.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 7/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import ObjectMapper

class QTUtils {

    static let shared = QTUtils()
    
    var userDefaults = UserDefaults.standard
    
    func saveRecentSearch(search: QTRecentSearchModel) {
        var recentSearches = getRecentSearches()
        if let index = recentSearches.firstIndex(where: { (item) -> Bool in
            if let itemName2 = item.name2, let searchItem2 = search.name2 {
                return  itemName2.lowercased().compare(searchItem2.lowercased()) == ComparisonResult.orderedSame &&
                        item.name1.lowercased().compare(search.name1.lowercased()) == ComparisonResult.orderedSame
            } else {
                return item.name1.lowercased().compare(search.name1.lowercased()) == ComparisonResult.orderedSame
            }
        }) {
            recentSearches.remove(at: index)
            recentSearches.insert(search, at: 0)
        } else {
            recentSearches.insert(search, at: 0)
        }
        
        userDefaults.set(recentSearches.toJSONString(), forKey: QTUserDefaultsKey.leanerRecentSearches)
        userDefaults.synchronize()
    }
    
    func removeRecentSearch(search: QTRecentSearchModel) {
        var recentSearches = getRecentSearches()
        if let index = recentSearches.firstIndex(where: { (item) -> Bool in
            if let itemName2 = item.name2, let searchItem2 = search.name2 {
                return  itemName2.lowercased().compare(searchItem2.lowercased()) == ComparisonResult.orderedSame &&
                    item.name1.lowercased().compare(search.name1.lowercased()) == ComparisonResult.orderedSame
            } else {
                return item.name1.lowercased().compare(search.name1.lowercased()) == ComparisonResult.orderedSame
            }
        }) {
            recentSearches.remove(at: index)
            userDefaults.set(recentSearches.toJSONString(), forKey: QTUserDefaultsKey.leanerRecentSearches)
            userDefaults.synchronize()
        }
    }
    
    func getRecentSearches() -> [QTRecentSearchModel] {
        
        var recentSearches: [QTRecentSearchModel]?
        if let recentSearchesString = userDefaults.string(forKey: QTUserDefaultsKey.leanerRecentSearches) {
            recentSearches = Mapper<QTRecentSearchModel>().mapArray(JSONString: recentSearchesString)
        }
        return recentSearches ?? []
    }
    
    func getFormatedName(name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return ""
        }
        let splitName = trimmed.split(separator: " ")
        if 1 < splitName.count {
            let formatted = "\(splitName[0]) \(String(splitName[1]).prefix(1))."
            return formatted
        } else {
            return trimmed
        }
    }
}

