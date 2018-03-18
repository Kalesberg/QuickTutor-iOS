//
//  UploadTutor.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class Tutor {
	
	private var ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
	private var storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	private var user = Auth.auth().currentUser!
	
	class var sharedManager : Tutor {
		struct Static {
			static let instance = Tutor()
		}
		return Static.instance
	}
	
	public func uploadTutor(userId: String!) -> Bool {
		var uploadSuccess = true
		//check all the values.
		if (userId == nil) || (userId == "") {
			return false
		}
		
		let post : [String:Any] =
			[
					"name" : "\(Registration.firstName!) \(Registration.lastName!)",
					"birthday" : "\(Registration.dob!)",
					"age" : Registration.age,
					"email": Registration.email,
					"phoneNumber" : Registration.phone,
					"bio" : TutorRegistration.tutorBio,
					"subjects" : "Subjects",
					"geohash" : "1231sdc12",
					"location" : "latitude, longitude",
					"filers" : "Filters",
					"stripeToken" : "token"
		]
		
		ref.child("tutor").child(userId).setValue(post) { (error, databaseRef) in
			if let error = error {
				print("Error: ", error.localizedDescription)
				uploadSuccess = false
			}else{
				print("User is in the database!")
			}
		}
		return uploadSuccess
	}
	
	public func updateValue(value: [String: Any]) -> Bool {
		var success = true
		ref.child("tutor").child("specific location").child(self.user.uid).updateChildValues(value) { (error, reference) in
			if let error = error {
				print(error.localizedDescription)
				success = false
			}else{
				print(reference)
			}
		}
		return success
	}
}


