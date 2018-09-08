//
//  LearnerModel.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/27/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class AWLearner {
	
	var uid : String = ""
	
	var name      : String!
	var bio       : String!
	var birthday  : String!
	var email       : String!
	var phone     : String!
	var lNumSessions : Int!
	var customer  : String!
		
	var school    : String?
	var languages : [String]?
	
	var lRating      : Double!
	
	var images = ["image1" : "", "image2" : "", "image3" : "", "image4" : ""]
	
	var connectedTutors = [String]()
	
	var isTutor : Bool = false
	var hasPayment : Bool = false
	
	init(dictionary: [String:Any]) {
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
	}
}
