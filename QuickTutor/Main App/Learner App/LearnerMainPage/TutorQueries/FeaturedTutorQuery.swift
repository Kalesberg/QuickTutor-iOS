//
//  FeaturedTutorQuery.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

struct TutorSubjectSearch {
	
	var uid : String = ""
	
	let rating : Double
	let price : Int
	let subjects : String
	let hours : Int
	let distancePreference : Int
	let numSessions : Int
	
	init(dictionary: [String : Any]) {
		
		rating = dictionary["r"] as? Double ?? 5.0

		subjects = dictionary["sbj"] as? String ?? ""
		
		price = dictionary["p"] as? Int ?? 0
		hours = dictionary["hr"] as? Int ?? 0
		numSessions = dictionary["nos"] as? Int ?? 0
		distancePreference = dictionary["dst"] as? Int ?? 0

	}
}

struct TutorSubcategory {
	
	var subcategory  = ""
	
	let price : Int
	let rating : Double
	let hours : Int
	let subjects : String
	let numSessions : Int
	
	init(dictionary: [String : Any]) {
		
		subjects 	= dictionary["sbj"] 	as? String ?? ""
		hours 	 	= dictionary["hr"] 	as? Int ?? 0
		price 	 	= dictionary["p"] 	as? Int ?? 0
		numSessions = dictionary["nos"] 	as? Int ?? 0
		rating   	= dictionary["r"] 	as? Double ?? 0.0
	}
}

struct TutorReview {
	
	var sessionId = ""
	
	let studentName : String
	let date : String
	let message : String
	let imageURL : String
	let subject : String
	
	let price : Int
	let rating : Double
	let duration : Int
	
	init(dictionary : [String : Any]) {
		
		date 		= dictionary["dte"] as? String ?? ""
		price 		= dictionary["p"] as? Int ?? 0
		message 	= dictionary["m"] as? String ?? ""
		subject 	= dictionary["sbj"] as? String ?? ""
		duration 	= dictionary["dur"] as? Int ?? 0
		imageURL 	= dictionary["img"] as? String ?? ""
		studentName = dictionary["nm"] as? String ?? ""
		
		rating 		= dictionary["r"] as? Double ?? 0.0
		
	}
}

struct TutorLocation1 {
	let geohash : String?
	let location : CLLocation?
	
	init(dictionary : [String : Any]) {
		geohash = dictionary["g"] as? String ?? nil
		guard let locationArray = dictionary["l"] as? [Double] else {
			location = nil
			return
		}
		location = CLLocation(latitude: locationArray[0], longitude: locationArray[1])
	}
}

class QueryData {
	
	static let shared = QueryData()
	
	private var ref : DatabaseReference? = Database.database().reference(fromURL: Constants.DATABASE_URL)
	
	public func queryAWTutorsByFeaturedCategory(categories: [Category],_ completion: @escaping ([Category : [AWTutor]]?) -> Void) {
		
		var tutors = [Category : [AWTutor]]()
		let group = DispatchGroup()
		
		queryAWTutorByUids(categories: categories) { (uids) in
			
			if let uids = uids {
				for key in uids {
					tutors[key.key] = []
					for uid in key.value {
						group.enter()
						FirebaseData.manager.getTutor(uid) { (tutor) in
							if let tutor = tutor {
								tutors[key.key]!.append(tutor)
							}
							group.leave()
						}
					}
				}
				group.notify(queue: .main) {
					completion(tutors)
				}
			}
		}
	}
	private func queryAWTutorByUids(categories: [Category],_ completion: @escaping ([Category : [String]]?) -> Void) {
		var uids = [Category : [String]]()
		let group = DispatchGroup()
		
		for category in categories {
			
			uids[category] = []
			let categoryString = category.mainPageData.displayName.lowercased()
			
			group.enter()
			
			self.ref?.child("featured").queryOrdered(byChild: "c").queryEqual(toValue: categoryString).queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snapshot) in
				for snap in snapshot.children {
					guard let child = snap as? DataSnapshot else { continue }
					if child.key == CurrentUser.shared.learner.uid { continue }

					uids[category]!.append(child.key)
				}
				group.leave()
			})
		}
		group.notify(queue: .main) {
			completion(uids)
		}
	}
	
	func queryAWTutorByCategory(category: Category, _ completion: @escaping ([AWTutor]?) -> Void) {
		
		var tutors : [AWTutor] = []
		let group = DispatchGroup()
		
		self.ref?.child("featured").queryOrdered(byChild: "c").queryEqual(toValue: category.mainPageData.displayName.lowercased()).queryLimited(toFirst: 20).observeSingleEvent(of: .value){ (snapshot) in
			
			for snap in snapshot.children {
				guard let child = snap as? DataSnapshot else { continue }
				if child.key == CurrentUser.shared.learner.uid { continue }

				group.enter()
				FirebaseData.manager.getTutor(child.key) { (tutor) in
					if let tutor = tutor {
						tutors.append(tutor)
					}
					group.leave()
				}
			}
			group.notify(queue: .main) {
				completion(tutors)
			}
		}
	}

	func queryAWTutorBySubject(subcategory: String, subject: String, _ completion: @escaping ([AWTutor]?) -> Void) {
		
		var tutors : [AWTutor] = []
		
		//var sortedTutors = [FeaturedTutor]()
		
		let group = DispatchGroup()
		
		self.ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: "p").queryStarting(atValue: 10).queryEnding(atValue: 255 + 10).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in
			
			for snap in snapshot.children {
				guard let child = snap as? DataSnapshot else { continue }
				if child.key == CurrentUser.shared.learner.uid { continue }

				group.enter()
				FirebaseData.manager.getTutor(child.key, { (tutor) in
					if let tutor = tutor {
						tutors.append(tutor)
					}
					group.leave()
				})
			}
			group.notify(queue: .main) {
				completion(tutors)
			}
		}
	}
	
	func queryAWTutorBySubcategory(subcategory: String, _ completion: @escaping ([AWTutor]?) -> Void) {
		
		var tutors = [AWTutor]()
		let group = DispatchGroup()
		
		self.ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: "r").queryStarting(atValue: 3.0).queryLimited(toFirst: 5).observeSingleEvent(of: .value) { (snapshot) in
			
			for snap in snapshot.children {
	
				guard let child = snap as? DataSnapshot else { continue }
				if child.key == CurrentUser.shared.learner.uid { continue }
				
				group.enter()
				FirebaseData.manager.getTutor(child.key, { (tutor) in
					if let tutor = tutor {
						tutors.append(tutor)
					}
					group.leave()
				})
			}
			group.notify(queue: .main) {
				completion(tutors)
			}
		}
	}
	
}
