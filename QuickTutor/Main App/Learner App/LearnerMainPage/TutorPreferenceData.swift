//
//  TutorPreferenceData.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import Foundation

struct TutorPreferenceData {
    let name: String
    let subjects: [String]
    let sessionPreference: Int
    let travelPreference: Int
    let pricePreference: Int
    
    init(dictionary: [String: Any]) {
        subjects = dictionary["subjects"] as? [String] ?? []
        sessionPreference = dictionary["session"] as? Int ?? 3
        travelPreference = dictionary["distance"] as? Int ?? 0
        pricePreference = dictionary["price"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
    }
}
