//
//  TutorModel.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/27/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class AWTutor: AWLearner {
    
    var tBio: String!
    var region: String!
    var policy: String?
    var acctId: String!
    var topSubject: String?
    
    var price: Int!
    var hours: Int!
    var distance: Int!
    var preference: Int!
    var tNumSessions: Int!
    
    var tRating: Double!
    var earnings: Double!
    
    var isVisible: Bool!
    
    var subjects: [String]?
    
    var selected: [Selected] = []
    var reviews: [Review]?
    var location: TutorLocation1?
    
    var hasConnectAccount: Bool = false
    var hasPayoutMethod: Bool = true
    
    override init(dictionary: [String: Any]) {
        super.init(dictionary: dictionary)
        
        policy = dictionary["pol"] as? String ?? ""
        region = dictionary["rg"] as? String ?? ""
        topSubject = dictionary["tp"] as? String ?? ""
        tBio = dictionary["tbio"] as? String ?? ""
        acctId = dictionary["act"] as? String ?? ""
        username = dictionary["usr"] as? String ?? ""
        price = dictionary["p"] as? Int ?? 0
        hours = dictionary["hr"] as? Int ?? 0
        distance = dictionary["dst"] as? Int ?? 75
        preference = dictionary["prf"] as? Int ?? 3
        tNumSessions = dictionary["nos"] as? Int ?? 0
        isVisible = ((dictionary["h"] as? Int) == 0) ? true : false
        tRating = dictionary["tr"] as? Double ?? 5.0
        earnings = dictionary["ern"] as? Double ?? 0.0
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
