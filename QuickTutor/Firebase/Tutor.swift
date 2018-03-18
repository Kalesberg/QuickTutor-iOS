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
	
	static let shared = Tutor()
	
	
	public func initTutor(completion: @escaping (Bool) -> Void) {
		let data = UserData.userData
		
		let post : [String:Any] =
			[
				"name" : "\(data.firstName) \(data.lastName)",
				"birthday" : "\(data.birthday)",
				"age" : data.age,
				"email": data.email,
				"phoneNumber" : data.phone,
				"bio" : TutorRegistration.tutorBio,
				"subjects" : "Subjects",
				"geohash" : "1231sdc12",
				"address" : "address",
				"location" : ["latitude, longitude"],
				"stripeToken" : "token"
		]
		
		ref.child("tutor").child(user.uid).setValue(post) { (error, databaseRef) in
			if let error = error {
				print(error.localizedDescription)
				completion(false)
			} else {
				print("User is in the database!")
				completion(true)
			}
		}
	}
	public func updateValue(value: [String : Any]) {
		self.ref.child("tutor").child(user.uid).updateChildValues(value) { (error, reference) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
}


