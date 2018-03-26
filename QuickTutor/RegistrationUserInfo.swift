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
	
	static var name : String!
    static var age : String!
    static var email : String!
    static var phone : String!
    static var studentImage : UIImage!
    static var studentImageURL : String!
	static var dob : String!
	static var emailCredential : AuthCredential!
    static var filters : [String]!
	
	func setRegistrationDefaults(){
		
		let defaults = UserDefaults.standard
		
		defaults.set(Registration.email, 			forKey: "email")
		defaults.set(false, 						forKey: "hasPaymentMethod")
		defaults.set(true,							forKey: "showTutorial")
		defaults.set(0, 							forKey: "numberOfCards")
		defaults.set(false, 						forKey: "hasBio")
		
		LocalImageCache.localImageManager.updateImageStored(image: Registration.studentImage, number: "1")
	}
}


