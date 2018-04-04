//
//  BecomeTutorData.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/16/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import CoreLocation

struct TutorRegistration {

    static var tutorBio    : String!
	static var subjects : [Selected]!
	static var address : String!
	static var location : CLLocation!
	
	//stripe - connect
	static var bankholderName : String!
	static var last4SSN : String!
	static var routingNumber : String!
	static var accountNumber : String!
	static var stripeToken : String!
	static var city : String!
	static var line1 : String!
	static var zipcode : String!
	static var state : String!
}



