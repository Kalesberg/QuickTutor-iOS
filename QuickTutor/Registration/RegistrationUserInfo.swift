//
//  RegistrationUserInfo.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

import UIKit
import FirebaseAuth
import CoreLocation

struct DeviceInfo {
    static var keyboardHeight: Double!
    static var textFieldFontSize: Double!
    static var statusbarHeight: Double!
    static var multiplier: Double!
}

struct Registration {
	
	static let registrationManager = Registration()
	
    static var firstName : String!
    static var lastName : String!
    static var age : String!
    static var email : String!
    static var phone : String!
    static var studentImage : UIImage!
    static var studentImageURL : String!
	static var dob : String!
	static var emailCredential : AuthCredential!
    static var filters : [String]!
	static var customerId : String!
	
	func setRegistrationDefaults(){
		
		let defaults = UserDefaults.standard
		
		defaults.set(Registration.email, 			forKey: "email")
		defaults.set(Registration.customerId, 		forKey: "customerId")
		defaults.set(false, 						forKey: "hasPaymentMethod")
		defaults.set(true,							forKey: "showTutorial")
		defaults.set(0, 							forKey: "numberOfCards")
		defaults.set(false, 						forKey: "hasBio")
		
		LocalImageCache.localImageManager.updateImageStored(image: Registration.studentImage, number: "1")
	}
}

struct TutorRegistration {
	
    static var tutorBio    : String!
    static var subjects : [String]!
    static var filters : [String]!
	
	//stripe - connect
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
