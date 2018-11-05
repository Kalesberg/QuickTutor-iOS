//
//  TutorSubcategory.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

struct TutorSubcategory {
	var subcategory = ""
	
	let price: Int
	let rating: Double
	let hours: Int
	let subjects: String
	let numSessions: Int
	
	init(dictionary: [String: Any]) {
		subjects = dictionary["sbj"] as? String ?? ""
		hours = dictionary["hr"] as? Int ?? 0
		price = dictionary["p"] as? Int ?? 0
		numSessions = dictionary["nos"] as? Int ?? 0
		rating = dictionary["r"] as? Double ?? 0.0
	}
}
