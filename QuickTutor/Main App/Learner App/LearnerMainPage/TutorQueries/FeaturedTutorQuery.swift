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
	
	//	let review : [TutorReview]
	//	let subject : [TutorSubject]
	
}

class QueryData {
	
	static let shared = QueryData()
	
	private var ref : DatabaseReference? = Database.database().reference(fromURL: Constants.DATABASE_URL)
	
	private var feature = [Category : [FeaturedTutor]]()
	private var tutors = [FeaturedTutor]()
	
	public func queryFeaturedTutor(categories: [Category], _ completion: @escaping ([Category: [FeaturedTutor]]?, Error?) -> Void) {
		
		let dispatch = DispatchGroup()

		for category in categories {
			
			feature[category] = []
			
			let categoryString = category.subcategory.fileToRead
			
			dispatch.enter()
			
			self.ref?.child("featured").queryOrdered(byChild: "c").queryEqual(toValue: categoryString).queryLimited(toFirst: 20).observeSingleEvent(of: .value) { (snapshot) in
				
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
						self.feature[category]!.append(FeaturedTutor(name: name, region: region, school: school, topSubject: topSubject, bio: bio, policy: policy, hours: hours, price: price, numSessions: numSessions, rating: rating, language: language, token: token))
						
						dispatch.leave()
					})
				}
				dispatch.leave()
			}
		}
		dispatch.notify(queue: .main) {
			completion(self.feature, nil)
		}
	}
	
	func queryByCategory(category: Category, _ completion: @escaping ([FeaturedTutor]?) -> Void) {
		
		let dispatch = DispatchGroup()
	
		self.ref?.child("featured").queryOrdered(byChild: "c").queryEqual(toValue: category.mainPageData.displayName.lowercased()).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in
			
//			var tutors : [FeaturedTutor] = []
			
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
					self.tutors.append(FeaturedTutor(name: name, region: region, school: school, topSubject: topSubject, bio: bio, policy: policy, hours: hours, price: price, numSessions: numSessions, rating: rating, language: language, token: token))
					
					
					dispatch.leave()
				})
			}
			dispatch.notify(queue: .main) {
				completion(self.tutors)
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

		var tutors : [String] = []
		//pull people from the subcategory selected.
		self.ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: "t").queryLimited(toFirst: 50).observeSingleEvent(of: .value) { (snapshot) in

			for snap in snapshot.children {
				let child = snap as! DataSnapshot
				self.ref?.child("tutor-info").child(child.key).observeSingleEvent(of: .value, with: { (snapshot) in
					//						var tutor = FeaturedTutor.shared
					let value = child.value as? NSDictionary

					//						tutor.name   = value?["nm"  ] as! String
					//						tutor.image  = value?["img" ] as! String
					//						tutor.price  = value?["" ] as! String
					//						tutor.region = value?["region"] as! String
					//						tutor.topic  = value?["t"     ] as! String
					//
					//						tutors.append(tutor)

					completion(nil) //was tutor

				})
			}
		}
	}
}
