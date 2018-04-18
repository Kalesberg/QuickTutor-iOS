//
//  FeaturedTutorQuery.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

struct TutorSubjectSearch {
	
	let userId : String
	let rating : Double
	let price : Int
	let subjects : String
	let hours : Int
	let distancePreference : Int
	let numSessions : Int
}

struct TutorSubcategory {
	
	let subcategory : String
	let price : Int
	let rating : Double
	let hours : Int
	let subjects : String
	let numSessions : Int
	
}

struct TutorReview {
	
	let sessionId : String
	let studentName : String
	let date : String
	let message : String
	let imageURL : String
	let subject : String
	
	let price : Int
	let rating : Double
	let duration : Int
	
}

struct FeaturedTutor {
	
	static let shared = FeaturedTutor()
	
	var uid    : String!
	var name   : String!
	var region : String!
	var school : String!
	var topSubject : String!
	var bio : String!
	
	var preference : Int!
	var distance : Int!
	var hours : Int!
	var price : Int!
	
	var numSessions : Int!
	
	var rating : Double!
	
	var language  : [String]!
	var imageUrls : [String : String]!
	
	var token 	  : String!
	
	var reviews : [TutorReview]?
	var subjects : [String]!
	
}

class QueryData {
	
	static let shared = QueryData()
	
	private var ref : DatabaseReference? = Database.database().reference(fromURL: Constants.DATABASE_URL)
	
	public func queryFeaturedTutor(categories: [Category], _ completion: @escaping ([Category: [FeaturedTutor]]?) -> Void) {
		
		let group = DispatchGroup()
		
		var feature = [Category : [FeaturedTutor]]()
		
		for category in categories {
			
			group.enter()
			
			feature[category] = []
			
			let categoryString = category.mainPageData.displayName.lowercased()
			
			self.ref?.child("featured").queryOrdered(byChild: "c").queryEqual(toValue: categoryString).queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
				
				for snap in snapshot.children {
					
					group.enter()

					let child = snap as! DataSnapshot
					
					self.ref?.child("tutor-info").child(child.key).observeSingleEvent(of: .value, with: { (snapshot) in
						
						var valid : Bool = true
						
						var tutor = FeaturedTutor.shared
						
						if let value = snapshot.value as? [String : AnyObject] {
							
							tutor.uid = child.key
							
							if let name = value["nm"] as? String {
								tutor.name = name
							} else {
								print("name")
								
								valid = false
							}
							
							if let region = value["rg"] as? String {
								tutor.region = region
							} else {
								print("region")
								
								valid = false
							}
							if let school = value["sch"] as? String {
								tutor.school = school
							} else {
								print("school")
								
								valid = false
							}
							if let imageURLs = value["img"] as? [String : String] {
								tutor.imageUrls = imageURLs
							} else {
								valid = false
							}
							if let language = value["lng"] as? [String] {
								tutor.language = language
							} else {
								print("languge")
								
								valid = false
							}
							if let bio = value["bio"] as? String{
								tutor.bio = bio
							} else {
								print("bio")
								
								valid = false
							}
							if let distance = value["dst"] as? Int {
								tutor.distance = distance
							} else {
								print("distance")
								
								valid = false
							}
							if let preference = value["prf"] as? Int {
								tutor.preference = preference
							} else {
								print("preference")
								
								valid = false
							}
							if let hours = value["hr"] as? Int{
								tutor.hours = hours
							} else {
								print("hr")
								
								valid = false
							}
							if let rating = value["r"] as? Double{
								tutor.rating = rating
							} else {
								print("r")
								
								valid = false
							}
							if let numSessions = value["nos"] as? Int{
								tutor.numSessions = numSessions
							} else {
								print("nos")
								
								valid = false
							}
							if let price = value["p"] as? Int{
								tutor.price = price
							} else {
								print("p")
								valid = false
							}
							if let topSubject = value["tp"] as? String {
								tutor.topSubject = topSubject
							} else {
								valid = false
							}
						}
						
						if valid {
							feature[category]!.append(tutor)
						}
						group.leave()
					})
				}
				group.leave()
			}
		}
		group.notify(queue: .main) {
			completion(feature)
		}
	}
	
	func queryByCategory(category: Category, _ completion: @escaping ([FeaturedTutor]?) -> Void) {
		
		let group = DispatchGroup()
		var tutors : [FeaturedTutor] = []
		
		self.ref?.child("featured").queryOrdered(byChild: "c").queryEqual(toValue: category.mainPageData.displayName.lowercased()).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in
			
			for snap in snapshot.children {
				group.enter()
				
				let child = snap as! DataSnapshot
				
				self.loadTutorData(userId: child.key, { (tutor) in
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
	
	func queryBySubject(subcategory: String, subject: String, _ completion: @escaping ([FeaturedTutor]?) -> Void) {
		
		var tutors = [TutorSubjectSearch]()
		
		var sortedTutors = [FeaturedTutor]()
		
		let group = DispatchGroup()
		
		self.ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: "p").queryStarting(atValue: 10).queryEnding(atValue: 255 + 10).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in
			
			if let snap = snapshot.children.allObjects as? [DataSnapshot] {
				
				for child in snap {
					
					let userid = child.key
					
					guard let value = child.value as? [String : AnyObject],
						
						let price = value["p"] as? Int,
						let distancePreference = value["dst"] as? Int,
						let hours = value["hr"] as? Int,
						let rating = value["r"] as? Double,
						let numSessions = value["nos"] as? Int,
						let subjects = value["sbj"] as? String
						
						else {
							print("fail")
							continue
					}
					
					tutors.append(TutorSubjectSearch(userId: userid, rating: rating, price: price, subjects: subjects, hours: hours, distancePreference: distancePreference, numSessions: numSessions))
				}
				
				for tutor in tutors {

					group.enter()
					
					self.loadTutorData(userId: tutor.userId, { (tutor) in
						
						if let tutor = tutor {
							
							sortedTutors.append(tutor)
							
						}
						group.leave()
					})
				}
				group.notify(queue: .main, execute: {
					
					completion(sortedTutors)
				})
			} else {
				completion(nil)
			}
		}
	}
	
	func queryBySubcategory(subcategory: String, _ completion: @escaping ([FeaturedTutor]?) -> Void) {
		
		var tutors = [FeaturedTutor]()
		let group = DispatchGroup()
		
		self.ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: "r").queryStarting(atValue: 3.0).queryLimited(toFirst: 5).observeSingleEvent(of: .value) { (snapshot) in
			
			for snap in snapshot.children {
				
				group.enter()
				
				let child = snap as! DataSnapshot
				
				self.loadTutorData(userId: child.key, { (tutor) in
					
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

extension QueryData {
	
	private func loadTutorData(userId : String, _ completion: @escaping (FeaturedTutor?) -> Void) {
		
		self.ref?.child("tutor-info").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
			
			var valid : Bool = true
			
			var tutor = FeaturedTutor.shared
			
			
			if let value = snapshot.value as? [String : AnyObject] {
				
				tutor.uid = userId
				
				if let name = value["nm"] as? String {
					tutor.name = name
				} else {
					print("name")
					
					valid = false
				}
				
				if let region = value["rg"] as? String {
					tutor.region = region
				} else {
					print("region")
					
					valid = false
				}
				if let school = value["sch"] as? String {
					tutor.school = school
				} else {
					
				}
				if let imageURLs = value["img"] as? [String : String] {
					tutor.imageUrls = imageURLs
				} else {
					valid = false
				}
				if let language = value["lng"] as? [String] {
					tutor.language = language
				} else {
					
				}
				if let bio = value["bio"] as? String{
					tutor.bio = bio
				} else {
					print("bio")
					
					valid = false
				}
				if let hours = value["hr"] as? Int{
					tutor.hours = hours
				} else {
					print("hr")
					
					valid = false
				}
				if let rating = value["r"] as? Double{
					tutor.rating = rating
				} else {
					print("r")
					
					valid = false
				}
				if let numSessions = value["nos"] as? Int{
					tutor.numSessions = numSessions
				} else {
					print("nos")
					
					valid = false
				}
				if let distance = value["dst"] as? Int {
					tutor.distance = distance
				} else {
					print("distance")
					
					valid = false
				}
				if let preference = value["prf"] as? Int {
					tutor.preference = preference
				} else {
					print("preference")
					
					valid = false
				}
				if let price = value["p"] as? Int{
					tutor.price = price
				} else {
					print("p")
					valid = false
				}
				if let topSubject = value["tp"] as? String {
					tutor.topSubject = topSubject
				} else {
					valid = false
				}
			}
			
			if valid {
				let group = DispatchGroup()
				
				group.enter()
				
				self.loadSubjects(uid: tutor.uid, { (subcategory) in
					var subjects : [String] = []
					
					if let subcategory = subcategory {
						
						for subject in subcategory {
							
							let this = subject.subjects.split(separator: "$")
							
							for i in this {
								subjects.append(String(i))
	
							}
						}
						tutor.subjects = subjects
					}
					group.leave()
				})
				
				group.enter()
				self.loadReviews(uid: tutor.uid, { (reviews) in
					if let reviews = reviews {
						tutor.reviews = reviews
					}
					group.leave()
				})
				
				group.notify(queue: .main, execute: {
					completion(tutor)
				})
			
			} else {
				completion(nil)
			}
		})
	}
	
	func loadReviews(uid : String, _ completion : @escaping ([TutorReview]?) -> Void) {
		
		var reviews : [TutorReview] = []

		self.ref?.child("review").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			
			if let snap = snapshot.children.allObjects as? [DataSnapshot] {
				
				for child in snap {
					
					let sessionId = child.key

					guard let value = child.value as? [String : AnyObject],
						
						let studentName = value["nm"] as? String,
						let date 		= value["dte"] as? String,
						let message 	= value["m"] as? String,
						let imageURL 	= value["img"] as? String,
						let subject 	= value["sbj"] as? String,
						let price 		= value["p"]   as? Int,
						let rating	 	= value["r"]   as? Double,
						let duration 	= value["dur"]   as? Int
						
						else {
							continue
					}
					reviews.append(TutorReview(sessionId: sessionId, studentName: studentName, date: date, message: message, imageURL: imageURL, subject: subject, price: price, rating: rating, duration: duration))
					print(reviews)
				}
			}
			completion(reviews)
		})
	}
	
	func loadSubjects(uid: String, _ completion: @escaping ([TutorSubcategory]?) -> Void) {
		
		var subcategories : [TutorSubcategory] = []
		
		self.ref?.child("subject").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			
			if let snap = snapshot.children.allObjects as? [DataSnapshot] {
				
				for child in snap {
					
					let subcategory = child.key
					
					guard let value = child.value as? [String : AnyObject],
						
						let price 	 	= value["p"] as? Int,
						let rating   	= value["r"] as? Double,
						let hours 	 	= value["hr"] as? Int,
						let subjects 	= value["sbj"] as? String,
						let numSessions = value["nos"] as? Int
						
						else {
							continue
					}
					
					subcategories.append(TutorSubcategory(subcategory: subcategory, price: price, rating: rating, hours: hours, subjects: subjects, numSessions: numSessions))
				}
			}
			completion(subcategories)
		})
	}
}
