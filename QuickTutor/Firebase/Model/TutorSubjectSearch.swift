//
//  TutorSubjectSearch.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

struct TutorSubjectSearch {
	var uid: String = ""
	
	let rating: Double
	let price: Int
	let subjects: String
	let hours: Int
	let distancePreference: Int
	let numSessions: Int
	
	init(dictionary: [String: Any]) {
		rating = dictionary["r"] as? Double ?? 5.0
		
		subjects = dictionary["sbj"] as? String ?? ""
		
		price = dictionary["p"] as? Int ?? 0
		hours = dictionary["hr"] as? Int ?? 0
		numSessions = dictionary["nos"] as? Int ?? 0
		distancePreference = dictionary["dst"] as? Int ?? 0
	}
}
