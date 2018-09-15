//
//  UserSession.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

struct UserSession {
	
	var id : String = ""
	let otherId : String
	let status : String
	let subject : String
	let type : String
	let startTime : Int
	let endTime : Int
	let date : Double
	let expiration : Double
	let price : Int
	let cost : Double
	
	//0 = no reports, 1 = learner reported, 2 = tutor reported, 3 = both reported
	let reportStatus : Int

	var name : String = ""
	var imageURl : String = ""
	
	init(dictionary: [String: Any]) {
		date = dictionary["date"] as? Double ?? 0.0
		endTime = dictionary["endTime"] as? Int ?? 0
		expiration = dictionary["expiration"] as? Double ?? 0.0
		price = dictionary["price"] as? Int ?? 0
		startTime = dictionary["startTime"] as? Int ?? 0
		status = dictionary["status"] as? String ?? ""
		subject = dictionary["subject"] as? String ?? ""
		type = dictionary["type"] as? String ?? ""
		otherId = (AccountService.shared.currentUserType == .learner) ? dictionary["receiverId"] as? String ?? "" : dictionary["senderId"] as? String ?? ""
		reportStatus = dictionary["reported"] as? Int ?? 0
		cost = dictionary["cost"] as? Double ?? 0
	}
}
