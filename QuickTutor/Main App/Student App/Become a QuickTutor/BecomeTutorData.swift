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
    static var subjects : [String]!
    static var filters : [String]!
	
	//stripe - connect
	
	static var bankholderName : String!
	static var country    : String!
	static var city : String!
	static var zipcode : String!
	static var address_line1 : String!
	static var state : String!
	static var last4SSN : String!
	static var routingNumber : String!
	static var accountNumber : String!
	static var location : [CLLocationDegrees]!
	static var geohash : String!
	
}

