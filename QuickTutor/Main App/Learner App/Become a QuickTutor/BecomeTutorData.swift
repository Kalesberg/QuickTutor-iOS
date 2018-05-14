//
//  BecomeTutorData.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/16/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import CoreLocation
import Stripe

struct TutorRegistration {

    static var tutorBio    : String!
	static var subjects : [Selected]!
	static var address : String!
	static var location : CLLocation!
	static var price : Int!
	static var distance : Int!
	static var sessionPreference : Int!
	static var username : String!
	
	static var last4SSN : String!
	static var line1 : String!
	static var city : String!
	static var state : String!
	static var zipcode : String!

	static var bankToken : STPToken!
	static var connectAccountToken : STPToken!
	
	static var acctId : String!
}



