//
//  FeaturedTutorQuery.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

struct TutorSubject {
	
	let price : String
	let rating : String
	let hours : String
	let subjects : [String]
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
	let rating : Int
	let count : Int
	let duration : Int
	
}

struct FeaturedTutor {
	
	//static let shared = FeaturedTutor()
	
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
	
	//	let review : [TutorReview]
	//	let subject : [TutorSubject]

}

/*
	I think i can combine these queries into clearner looking functions that aren't so redundant. But for now im going to do it the long way to prevent me from doing further testing.
*/

class QueryData {
	
	static let shared = QueryData()
	
	private var ref : DatabaseReference? = Database.database().reference(fromURL: Constants.DATABASE_URL)
	
	public func queryFeaturedTutor(categories: [Category], _ completion: @escaping ([Category: [FeaturedTutor]]?, Error?) -> Void) {
		
		let dispatch = DispatchGroup()
		
		var feature = [Category : [FeaturedTutor]]()

		for category in categories {
			
			feature[category] = []
			
			let categoryString = category.mainPageData.displayName.lowercased()
			
			dispatch.enter()
			
			self.ref?.child("featured").queryOrdered(byChild: "c").queryEqual(toValue: categoryString).queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
				
				print(snapshot.childrenCount)

				
				for snap in snapshot.children {
					dispatch.enter()
					let child = snap as! DataSnapshot

					self.ref?.child("tutor-info").child(child.key).observeSingleEvent(of: .value, with: { (snapshot) in
						
						guard
							let value = snapshot.value as? [String : AnyObject],
							let name = value["nm"] as? String,
							let region = value["rg"] as? String,
							let school = value["sch"] as? String,
							//							let imageURLs = value["img"] as? [String],
							let language  = value["lng"] as? [String],
							let bio = value["bio"] as? String,
							let hours = value["hr"] as? Int,
							let rating = value["r"] as? Double,
							let numSessions = value["nos"] as? Int,
							let price = value["p"] as? Int,
							let topSubject = value["tp"] as? String,
							let policy = value["pol"] as? String,
							let token = value["tok"] as? String
							//							let reviews = value["rvw"] as? [String: [String : Any]],
							//							let subjects = value["rvw"] as? [String: [String : Any]]
							
							else {
								print("Failure")
								return
						}

						feature[category]!.append(FeaturedTutor(name: name, region: region, school: school, topSubject: topSubject, bio: bio, policy: policy, hours: hours, price: price, numSessions: numSessions, rating: rating, language: language, token: token))
						
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
	
		self.ref?.child("featured").queryOrdered(byChild: "c").queryEqual(toValue: category.mainPageData.displayName.lowercased()).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in
			var tutors = [FeaturedTutor]()
			
			for snap in snapshot.children {
				dispatch.enter()
				
				let child = snap as! DataSnapshot
				
				self.ref?.child("tutor-info").child(child.key).observeSingleEvent(of: .value, with: { (snapshot) in
					
					guard
						let value = snapshot.value as? [String : AnyObject],
						let name = value["nm"] as? String,
						let region = value["rg"] as? String,
						let school = value["sch"] as? String,
						//							let imageURLs = value["img"] as? [String],
						let language  = value["lng"] as? [String],
						let bio = value["bio"] as? String,
						let hours = value["hr"] as? Int,
						let rating = value["r"] as? Double,
						let numSessions = value["nos"] as? Int,
						let price = value["p"] as? Int,
						let topSubject = value["tp"] as? String,
						let policy = value["pol"] as? String,
						let token = value["tok"] as? String
						//							let reviews = value["rvw"] as? [String: [String : Any]],
						//							let subjects = value["rvw"] as? [String: [String : Any]]
						
						else {
							print("Failure")
							return
					}
					tutors.append(FeaturedTutor(name: name, region: region, school: school, topSubject: topSubject, bio: bio, policy: policy, hours: hours, price: price, numSessions: numSessions, rating: rating, language: language, token: token))
					
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
		self.ref?.child(subcategory).queryOrdered(byChild: "r").queryEqual(toValue: 5).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in

			for snap in snapshot.children {
				let child = snap as! DataSnapshot
				print(child.key)

			}
		}
	}
	func queryBySubcategory(subcategory: String, _ completion: @escaping ([FeaturedTutor]?) -> Void) {
		
		let dispatch = DispatchGroup()
		
		self.ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: "h").queryStarting(atValue: 9).queryLimited(toFirst: 5).observeSingleEvent(of: .value) { (snapshot) in
			
			var tutors = [FeaturedTutor]()
			
			for snap in snapshot.children {
				
				dispatch.enter()
				let child = snap as! DataSnapshot

				self.ref?.child("tutor-info").child(child.key).observeSingleEvent(of: .value, with: { (snapshot) in

					guard let value = snapshot.value as? [String : AnyObject],

						let name = value["nm"] as? String,
						let region = value["rg"] as? String,
						let school = value["sch"] as? String,
						//							let imageURLs = value["img"] as? [String],
						let language  = value["lng"] as? [String],
						let bio = value["bio"] as? String,
						let hours = value["hr"] as? Int,
						let rating = value["r"] as? Double,
						let numSessions = value["nos"] as? Int,
						let price = value["p"] as? Int,
						let topSubject = value["tp"] as? String,
						let policy = value["pol"] as? String,
						let token = value["tok"] as? String
						//							let reviews = value["rvw"] as? [String: [String : Any]],
						//							let subjects = value["rvw"] as? [String: [String : Any]]

					else {
						print("Failure")
						return
					}
					
					tutors.append(FeaturedTutor(name: name, region: region, school: school, topSubject: topSubject, bio: bio, policy: policy, hours: hours, price: price, numSessions: numSessions, rating: rating, language: language, token: token))
		
					dispatch.leave()
				})
			}
			dispatch.notify(queue: .main) {
				completion(tutors)
			}
		}
	}
}
