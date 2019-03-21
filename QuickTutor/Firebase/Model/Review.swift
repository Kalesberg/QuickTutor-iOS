//
//  Review.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

struct Review {
	var sessionId = ""
	
	let studentName: String
	let formattedDate: String
	let message: String
	let subject: String
	let rating: Double
	let reviewerId: String
	let timestamp : Double
    
    var formattedStudentName: String {
        get {
            let nameSplit = studentName.split(separator: " ")
            let formatted = "\(String(nameSplit[0]).capitalized) \(String(nameSplit[1]).capitalized.prefix(1))."
            return formatted
        }
    }

	
	init(dictionary: [String: Any]) {
		rating = dictionary["r"] as? Double ?? 0.0
		message = dictionary["m"] as? String ?? ""
		subject = dictionary["sbj"] as? String ?? ""
		timestamp = dictionary["dte"] as? Double ?? 0
		reviewerId = dictionary["uid"] as? String ?? ""
		studentName = dictionary["nm"] as? String ?? ""
		formattedDate = Int(timestamp).timeIntervalToReviewDateFormat()
	}
}
