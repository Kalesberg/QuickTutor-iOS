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

/*
	Still need to figure out how to put all of this data into a single Write
*/

class Tutor {
	
	private var ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
	private var storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	private var user = Auth.auth().currentUser!
	
	static let shared = Tutor()
	
	public func initTutor(completion: @escaping (Error?) -> Void) {
		
		let data = LearnerData.userData
		let subjectNode = buildSubjectNode()
		
		var post : [String : Any] =
			[
				"/tutor-info/\(user.uid)" :
					[
					  "nm"  : data.name,
					  "sch" : data.school,
					  "lng" : data.languages,
					  "img" : data.images,
					  "hr"  : 0,
					  "r"   : 5,
					  "nos" : 0,
					  "p"	: TutorRegistration.price,
					  "dst"	: TutorRegistration.distance,
					  "bio" : TutorRegistration.tutorBio,
					  "rg"  : "region",
					  "pol" : "5_5_5_5",
					  "prf" : TutorRegistration.sessionPreference,
					  "tp"  : "Math"],
				]
		
		post.merge(subjectNode.0) { (_, last) in last }
		post.merge(subjectNode.1) { (_, last) in last }
	
		ref.root.updateChildValues(post) { (error, databaseRef) in
			if let error = error {
				print(error.localizedDescription)
				completion(error)
			} else {
				//self.geoFire(location: TutorRegistration.location)
				completion(nil)
			}
		}
	}
	
	public func buildSubjectNode() -> ([String : Any], [String : Any]) {

		var subcategories : [String] = []
		
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
		
		var updateSubjectValues 	= [String : Any]()
		var updateSubcategoryValues = [String : Any]()
		
		for key in subjectDict {
			
			let subjects = key.value.compactMap({$0}).joined(separator: "$")
			
			updateSubjectValues["/subject/\(Auth.auth().currentUser!.uid)/\(key.key.lowercased())"] = ["p": TutorRegistration.price!, "r" : 5, "sbj" : subjects, "hr" : 0, "nos" : 0]
			
			updateSubcategoryValues["/subcategory/\(key.key.lowercased())/\(Auth.auth().currentUser!.uid)"] = ["r" : 5, "p" : TutorRegistration.price!, "dst" : TutorRegistration.distance!, "hr" : 0,"nos" : 0, "sbj" : subjects]
		}

		return (updateSubjectValues, updateSubcategoryValues)
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


