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
		let subjectNode = buildSubjectNode()
		
		let post : [String : Any] =
			[
				"/tutor-info/\(user.uid)" :
					[ "nm"  : data.name,
					  "sch" : data.school,
					  "lng" : data.languages,
					  "img" : data.images,
					  "hr"  : 0,
					  "r"   : 5,
					  "nos" : 0,
					  "p"	: 5,
					  "bio" : TutorRegistration.tutorBio,
					  "rg"  : TutorRegistration.address,
					  "tok" : TutorRegistration.stripeToken,],
				
				"/subject/\(user.uid)" : subjectNode,
				
				]
		
		ref.root.updateChildValues(post) { (error, databaseRef) in
			if let error = error {
				print(error.localizedDescription)
				completion(error)
			} else {
				print("User is in the database!")
				self.geoFire(location: TutorRegistration.location)
				self.placeTutor()
				completion(nil)
			}
		}
		
	}
	public func buildSubjectNode() -> [String : Any] {

		var subcategories : [String] = []
		var updateValues : [String : Any] = [:]
		var subjectDict = [String : [String]]()
		
		if let subjects = TutorRegistration.subjects {
			for (_, value) in subjects.enumerated() {
				subcategories.append(value.path)
			}
			
			for subcategory in subcategories.unique {
				
				let path = subcategory
				var arr : [String] = []
				
				for subject in subjects {
					if path == subject.path {
						arr.append(subject.subject)
					}
				}
				subjectDict[path] = arr
			}
		}
		for key in subjectDict {
			let subjects = key.value.compactMap({$0}).joined(separator: " ")
			updateValues["\(key.key.lowercased())"] = ["p": 5, "r" : 5, "sbj" : subjects, "h" : 0, "s" : 0]
		}
		return updateValues
	}
	
	private func placeTutor() {
		
		var paths : [String] = []
		var updateValues : [String : Any] = [:]
		
		if let subjects = TutorRegistration.subjects {
			for (_, value) in subjects.enumerated() {
				paths.append(value.path)
			}
		}
		for path in paths.unique {
			updateValues["subcategory/\(path)/\(Auth.auth().currentUser!.uid)"] = ["r" : 5, "p" : 5, "d" : 0, "h" : 0]
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


