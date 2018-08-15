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
 	let subject : String
	
	let price : Int
	let rating : Double
	let duration : Int
	let reviewerId : String
	
	init(dictionary : [String : Any]) {
		let timestamp = dictionary["dte"] as? Int ?? 0
		date 		= timestamp.timeIntervalToReviewDateFormat()
		price 		= dictionary["p"] as? Int ?? 0
		message 	= dictionary["m"] as? String ?? ""
		subject 	= dictionary["sbj"] as? String ?? ""
		duration 	= dictionary["dur"] as? Int ?? 0
		studentName = dictionary["nm"] as? String ?? ""
		reviewerId  = dictionary["uid"] as? String ?? ""
		rating 		= dictionary["r"] as? Double ?? 0.0
		
	}
}
struct FeaturedTutor {
	
	var uid : String = ""
	
	let name : String
	let price : Int
	let imageUrl : String
	let region : String
	let rating : Double
	let reviews : Int
	let subject : String
	let isHidden : Int
	
	init(dictionary : [String : Any]) {
		price = dictionary["p"] as? Int ?? 0
		imageUrl = dictionary["img"] as? String ?? ""
		region = dictionary["rg"] as? String ?? ""
		rating = dictionary["r"] as? Double ?? 5.0
		reviews = dictionary["rv"] as? Int ?? 0
		subject = dictionary["sbj"] as? String ?? ""
		isHidden = dictionary["h"] as? Int ?? 0

		if let nameSplit = (dictionary["nm"] as? String)?.split(separator: " ") {
			name = "\(nameSplit[0]) \(String(nameSplit[1]).prefix(1))."
		} else {
			name = ""
		}
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

	public func queryFeaturedTutors(categories: [Category],_ completion: @escaping ([Category : [FeaturedTutor]]?) -> Void) {
		var uids = [Category : [FeaturedTutor]]()
		let group = DispatchGroup()
		
		for category in categories {
			uids[category] = []
			let categoryString = category.subcategory.fileToRead
			
			group.enter()
			self.ref?.child("featured").child(categoryString).queryOrderedByKey().queryLimited(toFirst: 5).observeSingleEvent(of: .value, with: { (snapshot) in
				for snap in snapshot.children {
					guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid else { continue }
					group.enter()
					FirebaseData.manager.fetchFeaturedTutor(child.key, category: category.subcategory.fileToRead, { (tutor) in
						if let tutor = tutor {
							if tutor.isHidden == 0 {
								uids[category]!.append(tutor)
							}
						}
						group.leave()
					})
				}
				group.leave()
			})
		}
		group.notify(queue: .main) {
			completion(uids)
		}
	}
	
	func queryAWTutorByCategory(category: Category, lastKnownKey: String?, limit: UInt,_ completion: @escaping ([FeaturedTutor]?) -> Void) {
		var tutors : [FeaturedTutor] = []
		let group = DispatchGroup()
		let query : DatabaseQuery!
		
		if let lastKnownKey = lastKnownKey {
			query = self.ref?.child("featured").child(category.subcategory.fileToRead).queryOrderedByKey().queryStarting(atValue: lastKnownKey).queryLimited(toFirst: limit)
		} else {
			query = self.ref?.child("featured").child(category.subcategory.fileToRead).queryOrderedByKey().queryLimited(toFirst: limit)
		}
		
		query.observeSingleEvent(of: .value){ (snapshot) in
			for snap in snapshot.children {
				guard let child = snap as? DataSnapshot else { continue }
				group.enter()
				FirebaseData.manager.fetchFeaturedTutor(child.key, category: category.subcategory.fileToRead, { (tutor) in
					if let tutor = tutor {
						if tutor.isHidden == 0 {
							tutors.append(tutor)
						}
					}
					group.leave()
				})
			}
			group.notify(queue: .main) {
				if lastKnownKey != nil {
					tutors.removeFirst()
				}
				completion(tutors)
			}
		}
	}

	func queryAWTutorBySubject(subcategory: String, subject: String,_ completion: @escaping ([AWTutor]?) -> Void) {
		var tutors = [AWTutor]()
		let group = DispatchGroup()
		let formattedSubject = subject.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "#", with: "<").replacingOccurrences(of: ".", with: ">")

		self.ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: formattedSubject).queryEqual(toValue: formattedSubject).observeSingleEvent(of: .value, with: { (snapshot) in
			for snap in snapshot.children {
				guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid  else { continue }
				group.enter()
				FirebaseData.manager.fetchTutor(child.key, isQuery: true, { (tutor) in
					if let tutor = tutor {
						tutors.append(tutor)
					}
					group.leave()
				})
			}
			group.notify(queue: .main) {
				completion(tutors)
			}
		})
	}
	
	func queryAWTutorBySubcategory(subcategory: String, _ completion: @escaping ([AWTutor]?) -> Void) {
		
		var tutors = [AWTutor]()
		let group = DispatchGroup()
		
		self.ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: "r").queryStarting(atValue: 3.0).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in
			
			for snap in snapshot.children {
				guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid else { continue }
				group.enter()
				FirebaseData.manager.fetchTutor(child.key, isQuery: true, { (tutor) in
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
