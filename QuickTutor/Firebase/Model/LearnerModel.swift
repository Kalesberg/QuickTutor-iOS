//
//  LearnerModel.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/27/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class AWLearner: User {
    
    var name: String!
    var bio: String!
    var birthday: String!
    var email: String!
    var phone: String!
    var lNumSessions: Int!
    var customer: String!
    var lHours: Int!
    var school: String?
    var languages: [String]?
    var lReviews: [Review]!
    var lRating: Double!
    var isApplePayDefault = true
    var savedTutorIds = [String]()
    
    var images = ["image1": "", "image2": "", "image3": "", "image4": "", "image5": "", "image6": "", "image7": "", "image8": ""]
    
    var connectedTutors = [String]()
    
    var isTutor: Bool = false
    var hasPayment: Bool = false
	
	override var formattedName: String {
		get {
            guard let name = name, !name.isEmpty else {
                return ""
            }
			let nameSplit = name.split(separator: " ")
			let formatted = "\(String(nameSplit[0]).capitalized) \(String(nameSplit[1]).capitalized.prefix(1))."
			return formatted
		}
	}
	
    override init(dictionary: [String: Any]) {
        super.init(dictionary: dictionary)
        
        name = dictionary["nm"] as? String ?? ""
        bio = dictionary["bio"] as? String ?? ""
        birthday = dictionary["bd"] as? String ?? ""
        email = dictionary["em"] as? String ?? ""
        school = dictionary["sch"] as? String ?? nil
        phone = dictionary["phn"] as? String ?? ""
        languages = dictionary["lng"] as? [String] ?? nil
        customer = dictionary["cus"] as? String ?? ""
        lNumSessions = dictionary["nos"] as? Int ?? 0
        lRating = dictionary["r"] as? Double ?? 0.0
        lHours = dictionary["hr"] as? Int ?? 0
        isApplePayDefault = dictionary["isApplePayDefault"] as? Bool ?? true
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
