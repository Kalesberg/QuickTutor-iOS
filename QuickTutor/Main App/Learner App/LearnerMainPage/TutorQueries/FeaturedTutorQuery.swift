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
	
	var hours : Int!
	var price : Int!
	
	var numSessions : Int!
	
	var rating : Double!
	
	var language  : [String]!
	var imageUrls : [String : String]!
	
	var token 	  : String!
	
}

/*
These queries can 100% be written better/less redundant, but for the sake of testing other things on the app i just copy and pasted most of them to make my life easier.
*/

class QueryData {
	
	static let shared = QueryData()
	
	private var ref : DatabaseReference? = Database.database().reference(fromURL: Constants.DATABASE_URL)
	
	public func queryFeaturedTutor(categories: [Category], _ completion: @escaping ([Category: [FeaturedTutor]]?) -> Void) {
		
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
								print(numSessions)
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
			completion(feature)
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

		var tutors = [TutorSubjectSearch]()
		print("Hur")
		
		self.ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: "r").queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in

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
							print("Fail")
							continue
					}
					
					tutors.append(TutorSubjectSearch(rating: rating, price: price, subjects: subjects, hours: hours, distancePreference: distancePreference, numSessions: numSessions))
				
					//what are we comparing them to? user preferences? or our own standards? both?
				
				}
			}
			completion(nil)
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
