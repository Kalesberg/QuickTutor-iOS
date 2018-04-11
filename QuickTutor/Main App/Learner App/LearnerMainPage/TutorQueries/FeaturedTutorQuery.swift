//
//  FeaturedTutorQuery.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

struct TutorSubcategory {
	
	let price : Int
	let rating : Double
	let hours : Int
	let subjects : String
	let numSessions : Int
	
}

struct TutorReview {
	
	let sessionId : String
	let studentName : String
	let date : Date
	let message : String
	let imageURL : String
	let subject : String
	
	let price : Int
	let rating : Double
	let duration : Int
	
}

struct FeaturedTutor {
	
	static let shared = FeaturedTutor()
	
	var name   : String!
	var region : String!
	var school : String!
	var topSubject : String!
	var bio : String!
	var policy : String!
	
	var hours : Int!
	var price : Int!
	
	var numSessions : Int!
	
	var rating : Double!
	
	var language  : [String]!
	//var imageUrls = ["image1" : "", "image2" : "", "image3" : "", "image4" : ""]
	var token 	  : String!
	
	//	let review : [TutorReview]!
	//	let subject : [TutorSubject]!
	
}

/*
These queries can 100% be written better, but for the sake of testing other things on the app i just copy and pasted them.
*/

class QueryData {
	
	static let shared = QueryData()
	
	private var ref : DatabaseReference? = Database.database().reference(fromURL: Constants.DATABASE_URL)
	
	public func queryFeaturedTutor(categories: [Category], _ completion: @escaping ([Category: [FeaturedTutor]]?, Error?) -> Void) {
		
		let dispatch = DispatchGroup()
		
		var feature = [Category : [FeaturedTutor]]()
		
		for category in categories {
			
			dispatch.enter()
			
			feature[category] = []
			
			let categoryString = category.mainPageData.displayName.lowercased()
			
			self.ref?.child("featured").queryOrdered(byChild: "c").queryEqual(toValue: categoryString).queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
				
				for snap in snapshot.children {
					
					dispatch.enter()
					
					let child = snap as! DataSnapshot
					
					self.ref?.child("tutor-info").child(child.key).observeSingleEvent(of: .value, with: { (snapshot) in
						
						var valid : Bool = true
						
						var tutor = FeaturedTutor.shared
						
						if let value = snapshot.value as? [String : AnyObject] {
							
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
							//							let imageURLs = value["img"] as? [String],
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
							if let topSubject = value["tp"] as? String{
								tutor.topSubject = topSubject
							} else {
								print("tp")
								
								valid = false
							}
							if let policy = value["pol"] as? String{
								tutor.policy = policy
							} else {
								print("pol")
								valid = false
							}
							if let subjects = value["sbj"] as? [String : AnyObject] {
								self.normalizeSubjects(snapshot: <#T##DataSnapshot#>, <#T##completion: ([TutorSubcategory]?) -> Void##([TutorSubcategory]?) -> Void#>)
							} else {
								print("failure")
							}
						}
						
						if valid {
							feature[category]!.append(tutor)
						} else {
							print(child.key)
						}
						dispatch.leave()
					})
				}
				dispatch.leave()
			}
		}
		dispatch.notify(queue: .main) {
			completion(feature, nil)
		}
	}
	
	func queryByCategory(category: Category, _ completion: @escaping ([FeaturedTutor]?) -> Void) {
		
		let dispatch = DispatchGroup()
		var tutors : [FeaturedTutor] = []
		
		self.ref?.child("featured").queryOrdered(byChild: "c").queryEqual(toValue: category.mainPageData.displayName.lowercased()).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in
			
			for snap in snapshot.children {
				dispatch.enter()
				
				let child = snap as! DataSnapshot
				
				self.ref?.child("tutor-info").child(child.key).observeSingleEvent(of: .value, with: { (snapshot) in
					
					var valid : Bool = true
					var tutor = FeaturedTutor.shared
					
					if let value = snapshot.value as? [String : AnyObject] {
						
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
						//							let imageURLs = value["img"] as? [String],
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
						if let topSubject = value["tp"] as? String{
							tutor.topSubject = topSubject
						} else {
							print("tp")
							
							valid = false
						}
						if let policy = value["pol"] as? String{
							tutor.policy = policy
						} else {
							print("pol")
							valid = false
						}
					}
					
					if valid {
						tutors.append(tutor)
					} else {
						print(child.key)
					}
					
					dispatch.leave()
				})
			}
			dispatch.notify(queue: .main) {
				completion(tutors)
			}
		}
	}
	
	func queryBySubject(subcategory: String, subject: String, _ completion: @escaping ([FeaturedTutor]?) -> Void) {
		
		//var uids : [String]
		//	we will need to create codes for every subject so that we can query a range of similar subjects...
		self.ref?.child(subcategory).queryOrdered(byChild: "r").queryStarting(atValue: 3.0).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in
			
			for snap in snapshot.children {
				let child = snap as! DataSnapshot
				print(child.key)
				
			}
		}
	}
	
	func queryBySubcategory(subcategory: String, _ completion: @escaping ([FeaturedTutor]?) -> Void) {
		
		let dispatch = DispatchGroup()
		
		self.ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: "r").queryStarting(atValue: 3.0).queryLimited(toFirst: 5).observeSingleEvent(of: .value) { (snapshot) in
			
			var tutors = [FeaturedTutor]()
			
			for snap in snapshot.children {
				
				dispatch.enter()
				
				let child = snap as! DataSnapshot
				
				self.ref?.child("tutor-info").child(child.key).observeSingleEvent(of: .value, with: { (snapshot) in
					
					
					var valid : Bool = true
					var tutor = FeaturedTutor.shared
					
					if let value = snapshot.value as? [String : AnyObject] {
						
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
						//							let imageURLs = value["img"] as? [String],
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
						if let topSubject = value["tp"] as? String{
							tutor.topSubject = topSubject
						} else {
							print("tp")
							
							valid = false
						}
						if let policy = value["pol"] as? String{
							tutor.policy = policy
						} else {
							print("pol")
							valid = false
						}
					}
					
					if valid {
						tutors.append(tutor)
					} else {
						print(child.key)
					}
					
					dispatch.leave()
				})
			}
			dispatch.notify(queue: .main) {
				completion(tutors)
			}
		}
	}
}

extension QueryData {
	
	func normalizeReviews(snapshot : DataSnapshot, _ completion : @escaping ([TutorReview]?) -> Void) {
		var reviews : [TutorReview] = []

		for snap in snapshot.children {
			let child = snap as! DataSnapshot
			print(child)
			guard let value = child.value as? [String : AnyObject],
				
				let sessionId 	= value["sid"] as? String,
				let studentName = value["std"] as? String,
				let date 		= value["dte"] as? Date,
				let message 	= value["msg"] as? String,
				let imageURL 	= value["img"] as? String,
				let subject 	= value["sbj"] as? String,
				let price 		= value["p"]   as? Int,
				let rating	 	= value["r"]   as? Double,
				let duration 	= value["d"]   as? Int
				
				else {
					continue
			}
			
			reviews.append(TutorReview(sessionId: sessionId, studentName: studentName, date: date, message: message, imageURL: imageURL, subject: subject, price: price, rating: rating, duration: duration))
		}
		completion(reviews)
	}
	
	func normalizeSubjects(snapshot : DataSnapshot, _ completion : @escaping ([TutorSubcategory]?) -> Void) {
		var subcategories : [TutorSubcategory] = []
		
		for snap in snapshot.children {
			let child = snap as! DataSnapshot
			
			guard let value = child.value as? [String : AnyObject],
			
			let price 	 	= value["p"] as? Int,
			let rating   	= value["r"] as? Double,
			let hours 	 	= value["hr"] as? Int,
			let subjects 	= value["sbj"] as? String,
			let numSessions = value["nos"] as? Int
			
				else {
					continue
			}
			subcategories.append(TutorSubcategory(price: price, rating: rating, hours: hours, subjects: subjects, numSessions: numSessions))
		}
		completion(subcategories)
	}
}
