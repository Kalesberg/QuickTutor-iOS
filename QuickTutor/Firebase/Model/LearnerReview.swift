//
//  LearnerReview.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

struct LearnerReview {
	var sessionId = ""
	
	let tutorName: String
	let date: String
	let message: String
	let subject: String
	
	let price: Int
	let rating: Double
	let duration: Int
	let reviewerId: String
	
	init(dictionary: [String: Any]) {
		let timestamp = dictionary["dte"] as? Int ?? 0
		date = timestamp.timeIntervalToReviewDateFormat()
		price = dictionary["p"] as? Int ?? 0
		message = dictionary["m"] as? String ?? ""
		subject = dictionary["sbj"] as? String ?? ""
		duration = dictionary["dur"] as? Int ?? 0
		tutorName = dictionary["nm"] as? String ?? ""
		reviewerId = dictionary["uid"] as? String ?? ""
		rating = dictionary["r"] as? Double ?? 0.0
	}
}
