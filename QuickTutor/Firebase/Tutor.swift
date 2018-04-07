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
import GeoFire

class Tutor {
	
	private var ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
	private var storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	private var user = Auth.auth().currentUser!
	
	static let shared = Tutor()
	
	public func initTutor(completion: @escaping (Error?) -> Void) {
		
		let data = LearnerData.userData
		var paths : [String] = []
		var updateValues : [String : Any] = [:]
		
		
		if let subjects = TutorRegistration.subjects {
			for (_, value) in subjects.enumerated() {
				paths.append(value.path)
			}
		}
		for path in paths.unique {
			updateValues["tutor-info/\(Auth.auth().currentUser!.uid)\(path)/"] = []
		}
		
		let post : [String:Any] =
			[
				"nm" : data.name,
				"bio" : TutorRegistration.tutorBio,
				"sub" : "subjects",
				"rg" : TutorRegistration.address,
				"tok" : TutorRegistration.stripeToken,
            ]
		
		ref.child("tutor-info").child(user.uid).updateChildValues(post) { (error, databaseRef) in
			if let error = error {
				print(error.localizedDescription)
				completion(error)
			} else {
				print("User is in the database!")
				completion(nil)
			}
		}
		geoFire(location: TutorRegistration.location)
		placeTutor()
	}
	
	public func placeTutor() {
		
		var paths : [String] = []
		var updateValues : [String : Any] = [:]
		
		if let subjects = TutorRegistration.subjects {
			for (_, value) in subjects.enumerated() {
				paths.append(value.path)
			}
		}
		for path in paths.unique {
			updateValues["subcategory/\(path)/\(Auth.auth().currentUser!.uid)"] = ["r" : 5]
		}
	    self.ref.root.updateChildValues(updateValues)
	}
	
	public func updateValue(value: [String : Any]) {
		self.ref.child("tutor-info").child(user.uid).updateChildValues(value) { (error, reference) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
	public func geoFire(location: CLLocation) {
		let geoFire = GeoFire(firebaseRef: ref.child("tutor_loc"))
		geoFire.setLocation(location, forKey: user.uid)
	}
}
extension Array where Element : Hashable {
	var unique: [Element] {
		return Array(Set(self))
	}
}


