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

		let post : [String:Any] =
			[
				"nm" : "\(data.firstName!) \(data.lastName!)",
				"bd" : "\(data.birthday!)",
				"age" : data.age,
				"em": data.email,
				"phn" : data.phone,
				"bio" : TutorRegistration.tutorBio,
				"subj" : "subjects",
				"adr" : TutorRegistration.address,
				"tok" : TutorRegistration.stripeToken
		]
		
		ref.child("tutor").child(user.uid).setValue(post) { (error, databaseRef) in
			if let error = error {
				print(error.localizedDescription)
				completion(error)
			} else {
				print("User is in the database!")
				completion(nil)
			}
		}
		geoFire(location: TutorRegistration.location)
	}
	
	public func updateValue(value: [String : Any]) {
		self.ref.child("tutor").child(user.uid).updateChildValues(value) { (error, reference) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
	public func geoFire(location: CLLocationCoordinate2D) {
		let geoFire = GeoFire(firebaseRef: ref.child("tutor_loc"))
		geoFire.setLocation(CLLocation(latitude: 43.5965030, longitude: -84.7788380), forKey: user.uid)
	}
}


