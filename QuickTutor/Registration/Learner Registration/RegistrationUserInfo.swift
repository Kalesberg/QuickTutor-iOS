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
		
	static var uid : String!
	static var name : String!
    static var age : Int!
    static var email : String!
    static var phone : String!
    static var studentImage : UIImage!
    static var studentImageURL : String!
	static var dob : String!
	static var emailCredential : AuthCredential!
	static var imageData : Data!
	static var customerId : String!
	
	static func setRegistrationDefaults(){
		let defaults = UserDefaults.standard

		
		defaults.set(Registration.email, forKey: "email")
		//tutorials.
		defaults.set(true, forKey: "showMainPageTutorial1.0")
		defaults.set(true, forKey: "showTutorCardTutorial1.0")
		defaults.set(true, forKey: "showSubjectTutorial1.0")
		defaults.set(true, forKey: "showTutorSideBarTutorial1.0")
		defaults.set(true, forKey: "showTutorAddSubjectsTutorial1.0")
		defaults.set(true, forKey: "showHomePage")
		defaults.set(true, forKey: "showLearnerSideBarTutorial1.0")
		defaults.set(true, forKey: "showBecomeTutorTutorial1.0")
		defaults.set(true, forKey: "showMessagingSystemTutorial1.0")
	}
	static func setLearnerDefaults() {
		let defaults = UserDefaults.standard

		defaults.set(false, forKey: "showMainPageTutorial1.0")
		defaults.set(false, forKey: "showTutorCardTutorial1.0")
		defaults.set(false, forKey: "showSubjectTutorial1.0")
		defaults.set(true, forKey: "showHomePage")
		defaults.set(false, forKey: "showLearnerSideBarTutorial1.0")
		defaults.set(false, forKey: "showBecomeTutorTutorial1.0")
		defaults.set(false, forKey: "showMessagingSystemTutorial1.0")
	}
	static func setTutorDefaults() {
		let defaults = UserDefaults.standard

		defaults.set(false, forKey: "showMainPageTutorial1.0")
		defaults.set(false, forKey: "showTutorCardTutorial1.0")
		defaults.set(false, forKey: "showSubjectTutorial1.0")
		defaults.set(false, forKey: "showTutorSideBarTutorial1.0")
		defaults.set(false, forKey: "showTutorAddSubjectsTutorial1.0")
		defaults.set(false, forKey: "showHomePage")
		defaults.set(false, forKey: "showLearnerSideBarTutorial1.0")
		defaults.set(false, forKey: "showBecomeTutorTutorial1.0")
		defaults.set(false, forKey: "showMessagingSystemTutorial1.0")
	}
}


