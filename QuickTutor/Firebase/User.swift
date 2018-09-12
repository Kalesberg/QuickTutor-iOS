//
//  UploadUser.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

// TODO: add didSet functions and init() methods to classes to update the UI

import Firebase
import FirebaseDatabase
import FirebaseStorage
import Stripe
import CoreLocation
import SDWebImage
import SwiftKeychainWrapper

class CurrentUser {
	
	static let shared = CurrentUser()
	
	var learner : AWLearner!
	var tutor : AWTutor!
	var connectAccount : ConnectAccount!
}

class FirebaseData {
	
	static let manager = FirebaseData()
	
	private let ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
	private let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	private let user = Auth.auth().currentUser!
	
	/*
	MARK: // Learner Updates
	*/
	
	public func updateValue(node: String, value: [String : Any],_ completion: @escaping (Error?) -> Void) {
		return self.ref.child(node).child(user.uid).updateChildValues(value) { (error, reference) in
			if let error = error {
				return completion(error)
			}
			return completion(nil)
		}
	}
	public func updateTutorPostSession(uid: String, subcategory: String, tutorInfo: [String : Any], subcategoryInfo: [String : Any]) {
		self.ref.child("tutor-info").child(uid).updateChildValues(tutorInfo)
		self.ref.child("subject").child(uid).child(subcategory).updateChildValues(subcategoryInfo)
		self.ref.child("subcategory").child(subcategory).child(uid).updateChildValues(subcategoryInfo)
	}
	public func updateReviewPostSession(uid: String, type: String, review: [String:Any]) {
		self.ref.child("review").child(uid).child(type).childByAutoId().updateChildValues(review)
	}
	public func updateLearnerPostSession(uid: String, studentInfo: [String : Any]) {
		self.ref.child("student-info").child(uid).updateChildValues(studentInfo)
	}
	
	public func updateTutorVisibility(uid: String, status: Int) {
		return self.ref.child("tutor-info").child(uid).updateChildValues(["h" : status])
	}
	
	public func updateAdditionalQuestions(value: [String : Any], completion: @escaping (Error?) -> Void) {
		return self.ref.child("questions").child(user.uid).childByAutoId().updateChildValues(value) { (error,_) in
			if let error = error {
				return completion(error)
			}
			return completion(nil)
		}
	}
	public func updateTutorPreferences(uid: String, price: Int, distance: Int, preference: Int,_ completion: @escaping (Error?) -> Void) {
		let post : [String: Any] = ["p" : price, "dst" : distance, "prf": preference]
		return self.ref.child("tutor-info").child(uid).updateChildValues(post) { (error,_) in
			if let error = error {
				return completion(error)
			}
			return completion(nil)
		}
	}
	
	public func updateMobileNumber(phone: String, completion: @escaping (Error?) -> Void) {
		PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationId, error) in
			if let error = error {
				return completion(error)
			} else {
				UserDefaults.standard.set(verificationId, forKey: "reCredential")
				return completion(nil)
			}
		}
	}
	
	/*
	MARK: // Remove
	*/
	public func removeTutorAccount(uid: String, reason: String, subcategory: [String], message: String, _ completion: @escaping (Error?) -> Void) {
		
		var childNodes : [String : Any] = [:]
		
		childNodes["/connections/\(uid)"] = NSNull()
		childNodes["/conversations/\(uid)"] = NSNull()
		childNodes["/readReceipts/\(uid)"] = NSNull()
		childNodes["/review/\(uid)"] = NSNull()
		childNodes["/subject/\(uid)"] = NSNull()
		childNodes["/tutor-info/\(uid)"] = NSNull()
		childNodes["/tutor_loc/\(uid)"] = NSNull()
		childNodes["/userSessions/\(uid)"] = NSNull()
		childNodes["/deleted/\(uid)"] = ["reason" : reason, "message": message, "type" : "tutor", "name": CurrentUser.shared.learner.name, "phone": CurrentUser.shared.learner.phone, "email" : CurrentUser.shared.learner.email, "birthday" : CurrentUser.shared.learner.birthday]
		
		for subcat in subcategory {
			guard let category = SubjectStore.findCategoryBy(subcategory: subcat) else { continue }
			childNodes["/subcategory/\(subcat)/\(uid)"] = NSNull()
			childNodes["/featured/\(category)/\(uid)"] = NSNull()
		}
		
		return self.ref.updateChildValues(childNodes) { (error, _) in
			if let error = error {
				return completion(error)
			}
			UserDefaults.standard.set(true, forKey: "showHomePage")
			return completion(nil)
		}
	}
	
	public func removeBothAccounts(uid: String, reason: String, subcategory: [String], message: String, _ completion: @escaping (Error?) -> Void) {
		
		var childNodes = [String : Any]()
		
		childNodes["/account/\(uid)"] = NSNull()
		childNodes["/connections/\(uid)"] = NSNull()
		childNodes["/readReceipts/\(uid)"] = NSNull()
		childNodes["/review/\(uid)"] = NSNull()
		childNodes["/student-info/\(uid)"] = NSNull()
		childNodes["/subject/\(uid)"] = NSNull()
		childNodes["/tutor-info/\(uid)"] = NSNull()
		childNodes["/tutor_loc/\(uid)"] = NSNull()
		childNodes["/userSessions/\(uid)"] = NSNull()
		childNodes["/deleted/\(uid)"] = ["reason" : reason, "message": message, "type" : "both", "name": CurrentUser.shared.learner.name, "phone": CurrentUser.shared.learner.phone, "email" : CurrentUser.shared.learner.email, "birthday" : CurrentUser.shared.learner.birthday]

		for subcat in subcategory {
			childNodes["/subcategory/\(subcat)/\(uid)"] = NSNull()
			guard let category = SubjectStore.findCategoryBy(subcategory: subcat) else { continue }
			childNodes["/featured/\(category)/\(uid)"] = NSNull()
		}
		
		func removeImages(imageURL: [String]) {
			imageURL.forEach({
				Storage.storage().reference(forURL: $0).delete(completion: { (error) in
					if let error = error {
						print(error.localizedDescription)
					}
				})
			})
		}
		
		self.ref.updateChildValues(childNodes) { (error, _) in
			if let error = error {
				return completion(error)
			}
			removeImages(imageURL: CurrentUser.shared.learner.images.compactMap({$0.value}).filter({$0 != ""}))
			UserDefaults.standard.set(true, forKey: "showHomePage")
			return completion(nil)
		}
	}
	
	public func removeLearnerAccount(uid: String, reason: String,_ completion: @escaping (Error?) -> Void) {
		var childNodes = [String : Any]()
		
		childNodes["/student-info/\(uid)"] = NSNull()
		childNodes["/account/\(uid)"] = NSNull()
		childNodes["/deleted/\(uid)"] = ["reason" : reason,"email": CurrentUser.shared.learner.email, "type" : "learner", "time": NSDate().timeIntervalSince1970, "name": CurrentUser.shared.learner.name, "phone": CurrentUser.shared.learner.phone, "email" : CurrentUser.shared.learner.email, "birthday" : CurrentUser.shared.learner.birthday]
		
		func removeImages(imageURL: [String]) {
			imageURL.forEach({
				Storage.storage().reference(forURL: $0).delete(completion: { (error) in
					if let error = error {
						print(error.localizedDescription)
					}
				})
			})
		}
		self.ref.updateChildValues(childNodes) { (error, _) in
			if let error = error {
				return completion(error)
			}
			removeImages(imageURL: CurrentUser.shared.learner.images.compactMap({$0.value}).filter({$0 != ""}))
			return completion(nil)
		}
	}
	public func removeUserImage(_ number: String) {
		//Add completion Handler...
		if AccountService.shared.currentUserType == .learner {
			if CurrentUser.shared.learner.isTutor {
				ref.child("tutor-info").child(user.uid).child("img").updateChildValues(["image\(number)": ""])
			}
			ref.child("student-info").child(user.uid).child("img").updateChildValues(["image\(number)": ""])
			CurrentUser.shared.learner.images["image\(number)"] = ""
		} else {
			ref.child("tutor-info").child(user.uid).child("img").updateChildValues(["image\(number)": ""])
			ref.child("student-info").child(user.uid).child("img").updateChildValues(["image\(number)": ""])
			CurrentUser.shared.learner.images["image\(number)"] = ""
			CurrentUser.shared.tutor.images["image\(number)"] = ""
		}
		let reference = self.storageRef.child("student-info").child(CurrentUser.shared.learner.uid).child("student-profile-pic" + number)
		SDImageCache.shared().removeImage(forKey: reference.fullPath, fromDisk: true, withCompletion: nil)
		Storage.storage().reference().child("student-info/\(user.uid)/student-profile-pic\(number)").delete { (error) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
	
	
	/*
	MARK: // Fetch
	*/
	
	public func fetchTutorLocation(uid: String,_ completion: @escaping (TutorLocation1?) -> Void) {
		self.ref?.child("tutor_loc").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			if snapshot.exists() {
				guard let value = snapshot.value as? [String : Any] else { return }
				let tutorLocation = TutorLocation1(dictionary: value)
				return completion(tutorLocation)
			}
			return completion(nil)
		})
	}
	
	private func fetchTutorReviews(uid : String, _ completion : @escaping ([TutorReview]?) -> Void) {
		var reviews : [TutorReview] = []
		self.ref?.child("review").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			guard let snap = snapshot.children.allObjects as? [DataSnapshot] else { return }
			
			for child in snap {
				guard let value = child.value as? [String : Any] else { continue }
				
				var review = TutorReview(dictionary: value)
				review.sessionId = child.key
				reviews.append(review)
			}
			return completion(reviews)
		})
	}
	
	public func fetchTutorSubjects(uid: String, _ completion: @escaping ([TutorSubcategory]?) -> Void) {
		var subcategories : [TutorSubcategory] = []
		self.ref?.child("subject").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			if let snap = snapshot.children.allObjects as? [DataSnapshot] {
				for child in snap {
					guard let value = child.value as? [String : Any] else { continue }
					
					var subcategory = TutorSubcategory(dictionary: value)
					subcategory.subcategory = child.key
					subcategories.append(subcategory)
				}
			}
			return completion(subcategories)
		})
	}
	public func fetchSessionsWithPartner(uid: String,_ completion: @escaping(Error?) -> Void) {
		
	}
	public func fetchTutorSessionPreferences(uid: String,_ completion: @escaping([String : Any]?) -> Void) {
		self.ref.child("tutor-info").child(uid).observeSingleEvent(of: .value) { (snapshot) in
			var sessionDetails = [String : Any]()
			guard let value = snapshot.value as? [String : Any] else { return completion(nil) }
			
			sessionDetails["name"] = value["nm"] ?? ""
			sessionDetails["price"] = value["p"] ?? 20
			sessionDetails["preference"] = value["prf"] ?? 3
			sessionDetails["distance"] = value["dst"] ?? 150
			
			completion(sessionDetails)
		}
	}
	
	public func fetchLearnerConnections(uid: String, _ completion: @escaping ([String]?) -> Void) {
		var uids = [String]()
		self.ref.child("connections").child(uid).observeSingleEvent(of: .value) { (snapshot) in
			if let snap = snapshot.children.allObjects as? [DataSnapshot] {
				for child in snap {
					uids.append(child.key)
				}
			}
			return completion(uids)
		}
	}
	
	public func fetchProfileImages(uid: String,_ completion: @escaping ([String : String]?) -> Void) {
		ref.child("tutor-info").child(uid).child("img").observeSingleEvent(of: .value) { (snapshot) in
			if let value = snapshot.value as? [String : String] {
				return completion(value.filter({ $0.value != "" }))
			}
			return completion(nil)
		}
	}
	
	public func fetchTutorListings(uid: String,_ completion: @escaping ([Category: FeaturedTutor]?) -> Void) {
		var listings = [Category : FeaturedTutor]()
		let group = DispatchGroup()
		
		for category in Category.categories {
			group.enter()
			self.ref.child("featured").child(category.subcategory.fileToRead).child(uid).observeSingleEvent(of: .value) { (snapshot) in
				if snapshot.exists() {
					guard let value = snapshot.value as? [String : Any] else { return completion(nil) }
					var featuredTutor = FeaturedTutor(dictionary: value)
					featuredTutor.uid = snapshot.key
					listings[category] = featuredTutor
				}
				group.leave()
			}
		}
		group.notify(queue: .main) {
			return completion(listings)
		}
	}
	
	public func fetchRequestSessionData(uid: String,_ completion: @escaping (TutorPreferenceData?) -> Void) {
		var requestData = [String : Any]()
		let group = DispatchGroup()
		
		group.enter()
		fetchTutorSubjects(uid: uid) { (subcategory) in
			var subjects = [String]()
			guard let subcategory = subcategory else { return }
			for subject in subcategory {
				let subjectArray = subject.subjects.split(separator: "$")
				for i in subjectArray {
					subjects.append(String(i))
				}
				requestData["subjects"] = ["Choose a subject"] + subjects
			}
			group.leave()
		}
		group.enter()
		fetchTutorSessionPreferences(uid: uid, { (preferences) in
			guard let preferences = preferences else { return group.leave() }
			guard let price = preferences["price"] as? Int else { return group.leave() }
			guard let name = preferences["name"] as? String else { return group.leave() }
			guard let distance = preferences["distance"] as? Int else { return group.leave() }
			guard let preference = preferences["preference"] as? Int else { return  group.leave() }
			
			requestData["price"] = price
			requestData["session"] = preference
			requestData["distance"] = distance
			requestData["name"] = String(name.split(separator: " ")[0])
			
			group.leave()
		})
		group.notify(queue: .main) {
			completion(TutorPreferenceData(dictionary: requestData))
		}
	}
	public func fetchUserSessions(uid: String, type: String,_ completion: @escaping ([UserSession]?) -> Void) {
		var sessions = [UserSession]()
		let group = DispatchGroup()
		
		func fetchSessions(uid: String, type: String,_ completion: @escaping ([String]?) -> Void) {
			self.ref.child("userSessions").child(uid).child(type).observeSingleEvent(of: .value) { (snapshot) in
				guard let value = snapshot.value as? [String : Any] else { return completion(nil) }
				return completion(value.compactMap({$0.key}))
			}
		}
		
		fetchSessions(uid: uid, type: type) { (sessionIds) in
			guard let sessionIds = sessionIds else { return completion(nil) }
			for id in sessionIds {
				group.enter()
				self.ref.child("sessions").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
					guard let value = snapshot.value as? [String : Any] else { return group.leave() }
					guard let endTime = value["endTime"] as? Double, endTime > Date().timeIntervalSince1970 - 604800,
						endTime < Date().adding(minutes: 30).timeIntervalSince1970 else { return group.leave() }
					
					var session = UserSession(dictionary: value)
					session.id = id
					
					group.enter()
					self.ref.child("student-info").child(session.otherId).child("nm").observeSingleEvent(of: .value, with: { (snapshot) in
						session.name = snapshot.value as? String ?? ""
						sessions.append(session)
						group.leave()
					})
					group.leave()
				})
			}
			group.notify(queue: .main, execute: {
				completion(sessions)
			})
		}
	}
	//new functions for grabbing learner, tutor, and account data. not being used yet.
	public func fetchAccount(_ uid: String,_ completion: @escaping([String: Any]?) -> Void) {
		self.ref.child("account").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			guard let value = snapshot.value as? [String : Any] else { return completion(nil) }
			completion(value)
		})
	}
	public func fetchStudentInfo(_ uid: String,_ completion: @escaping([String: Any]?) -> Void) {
		self.ref.child("student-info").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			guard let value = snapshot.value as? [String : Any] else { return completion(nil) }
			completion(value)
		})
	}
	public func fetchTutorInfo(_ uid: String,_ completion: @escaping([String: Any]?) -> Void) {
		self.ref.child("tutor-info").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			guard let value = snapshot.value as? [String : Any] else { return completion(nil) }
			completion(value)
		})
	}
	
	public func fetchTutorSubjectStats(_ uid: String, subcategory: String,_ completion: @escaping ([String : Any]?) -> Void) {
		self.ref.child("subcategory").child(subcategory).child(uid).observeSingleEvent(of: .value) { (snapshot) in
			guard let value = snapshot.value as? [String : Any] else { return completion(nil) }
			completion(value)
		}
	}
	
	public func fetchLearner(_ uid : String,_ completion: @escaping (AWLearner?) -> Void) {
		let group = DispatchGroup()
		self.ref.child("account").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			guard let value = snapshot.value as? [String : Any] else { return completion(nil) }
			self.ref.child("student-info").child(uid).observeSingleEvent(of: .value, with: { (snapshot2) in
				guard let value2 = snapshot2.value as? [String : Any] else { return completion(nil) }
				
				let learnerData = value.merging(value2, uniquingKeysWith: { (first, last) -> Any in
					return last
				})
				
				let learner = AWLearner(dictionary: learnerData)
				learner.uid = uid
				
				group.enter()
				self.ref.child("tutor-info").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
					learner.isTutor = snapshot.exists()
					group.leave()
				})
				
				group.enter()
				self.fetchLearnerConnections(uid: uid, { (connections) in
					if let connections = connections {
						learner.connectedTutors = connections
					}
					group.leave()
				})
				guard let images = learnerData["img"] as? [String : String] else { return }
				learner.images = images
				
				group.notify(queue: .main) {
					completion(learner)
				}
			})
		})
	}
	public func fetchPendingRequests(uid:  String,_ completion: @escaping ([String]?) -> Void) {
		var conversationId = [String]()		
		self.ref.child("conversations").child(uid).child("learner").observe(.value) { (snapshot) in
			for snap in snapshot.children {
				guard let child = snap as? DataSnapshot else { continue }
				conversationId.append(child.key)
			}
			return completion(conversationId)
		}
	}
	
	public func fetchSubjectsTaught(uid: String,_ completion: @escaping ([TopSubcategory]) -> Void) {
		var subjectsTaught = [TopSubcategory]()
		
		ref.child("subject").child(uid).observeSingleEvent(of: .value) { (snapshot) in
			guard let snap = snapshot.children.allObjects as? [DataSnapshot] else { return }
			
			for child in snap {
				guard let value = child.value as? [String : Any] else { return }
				var topSubjects = TopSubcategory(dictionary: value)
				topSubjects.subcategory = child.key
				subjectsTaught.append(topSubjects)
			}
			return completion(subjectsTaught)
		}
	}
	//Not working yet. there are some things Fuller and I (Austin) have to collaborate on to make this work.
	public func checkIfSessionHasTimeConflict(_ uid: String, startTime: TimeInterval, endTime: TimeInterval,_ completion: @escaping (String?) -> Void) {
		
		self.ref.child("sessions").queryOrdered(byChild: "senderId").queryEqual(toValue: uid).observeSingleEvent(of: .value) { (snapshot) in
			for snap in snapshot.children {
				guard let child = snap as? DataSnapshot else { print("continue1"); continue }
				let value = child.value as! [String : Any]
				guard let sessionStartTime = value["startTime"] as? Double else { print("continu2e"); continue }
				guard let sessionEndTime = value["endTime"] as? Double else { print("continu3e"); continue }
			
				if (startTime < sessionEndTime) && endTime > (sessionStartTime) {
					print("Session overlaps.")
				} else {
					print("Session does not overlap.")
				}
			}
		}
	}
	
	public func fetchFeaturedTutor(_ uid: String, category: String,_ completion: @escaping (FeaturedTutor?) -> Void) {
		self.ref.child("featured").child(category).child(uid).observeSingleEvent(of: .value) { (snapshot) in
			guard let value = snapshot.value as? [String : Any] else { return completion(nil) }

			var featuredTutor = FeaturedTutor(dictionary: value)
			featuredTutor.uid = snapshot.key
			return completion(featuredTutor)
		}
	}
	
	public func fetchTutor(_ uid: String, isQuery: Bool,_ completion: @escaping (AWTutor?) -> Void) {
		
		let group = DispatchGroup()
		
		self.ref.child("account").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			guard let value = snapshot.value as? [String : Any] else { return completion(nil) }
			
			self.ref.child("tutor-info").child(uid).observeSingleEvent(of: .value, with: { (snapshot2) in
				guard let value2 = snapshot2.value as? [String : Any] else { return completion(nil) }
				let tutorDict = value.merging(value2, uniquingKeysWith: { (first, last) -> Any in
					return last
				})
				
				let tutor = AWTutor(dictionary: tutorDict)
				tutor.uid = uid
				
				if isQuery && (tutorDict["h"] as? Int == 1) {
					return completion(nil)
				}
				
				guard let images = tutorDict["img"] as? [String : String] else {
					print("Couldn't find images: ", uid)
					return completion(nil)
				}
				tutor.images = images
				
				self.fetchTutorLocation(uid: uid, { (location) in
					if let location = location {
						tutor.location = location
					}
				})
				
				group.enter()
				self.fetchTutorReviews(uid: uid, { (reviews) in
					if let reviews = reviews {
						tutor.reviews = reviews
					}
					group.leave()
				})
				group.enter()
				self.fetchTutorSubjects(uid: uid, { (subcategory) in
					var subjects : [String] = []
					var selected : [Selected] = []
					
					if let subcategory = subcategory {
						for subject in subcategory {
							let this = subject.subjects.split(separator: "$")
							for i in this {
								selected.append(Selected(path: "\(subject.subcategory)", subject: String(i)))
								subjects.append(String(i))
							}
						}
						tutor.subjects = subjects
						tutor.selected = selected
					}
					group.leave()
				})
				group.notify(queue: .main, execute: {
					completion(tutor)
				})
			})
		})
	}
	
	public func linkEmail(email: String) {
		let password: String? = KeychainWrapper.standard.string(forKey: "emailAccountPassword")
		let credential = EmailAuthProvider.credential(withEmail: email, password: password!)
		user.linkAndRetrieveData(with: credential) { (result, error) in
			if let error = error {
				print(error.localizedDescription)
			} else if let result = result {
				print(result)
			}
		}
	}
	
	public func uploadUser(_ completion: @escaping (Error?) -> Void) {
		
		let account : [String : Any] = ["phn" : Registration.phone,"age" : Registration.age, "em" : Registration.email, "bd" : Registration.dob, "logged" : "", "init" : (Date().timeIntervalSince1970 * 1000)]
		
		let studentInfo : [String : Any] = ["nm" : Registration.name, "r" : 5.0,
											"img": ["image1" : Registration.studentImageURL, "image2" : "", "image3" : "", "image4" : ""]]
		
		let newUser = ["/account/\(user.uid)/" : account, "/student-info/\(user.uid)/" : studentInfo]
		
		self.ref.root.updateChildValues(newUser) { (error, reference) in
			if let error = error {
				return completion(error)
			}
			return completion(nil)
		}
	}
	
	public func fileReport(sessionId: String, reportStatus: Int, value: [String : Any], completion: @escaping (Error?) -> Void) {
		self.ref.child("filereport").child(user.uid).child(sessionId).updateChildValues(value) { (error, reference) in
			if let error = error {
				return completion(error)
			}
			//use this to mark a session that has already been reported.
			//self.ref.child("sessions").child(sessionId).updateChildValues(["reported" : reportStatus])
			return completion(nil)
		}
	}
	public func updateListing(tutor: AWTutor, category: String, image: UIImage, price: Int, subject: String,_ completion: @escaping (Bool) -> Void) {
		func uploadFeaturedImage(_ completion: @escaping(String?) -> Void) {
			guard let data = getCompressedImageDataFor(image) else { return completion(nil) }
			self.storageRef.child("featured").child(tutor.uid).child("featuredImage").putData(data, metadata: nil) { (meta, error) in
				if error != nil {
					return completion(nil)
				}
				self.storageRef.child("featured").child(tutor.uid).child("featuredImage").downloadURL(completion: { (url, error) in
					if error != nil {
						return completion(nil)
					}
					guard let imageUrl = url?.absoluteString else { return completion(nil) }
					return completion(imageUrl)
				})
			}
		}
		uploadFeaturedImage { (imageUrl) in
			if let imageUrl = imageUrl {
				let post : [String : Any] = ["img" : imageUrl, "nm" : tutor.name, "p" : price, "r": tutor.tRating, "rv": tutor.reviews?.count ?? 0, "sbj" : subject, "rg" : tutor.region, "t" : UInt64(NSDate().timeIntervalSince1970 * 1000.0), "h" : 0]
		
				self.ref.child("featured").child(category).child(tutor.uid).updateChildValues(post)
				completion(true)
			} else {
				completion(false)
			}
		}
	}
	
	public func hideListing(uid: String, category: String, isHidden: Int) {
		let value = ["h" : isHidden == 0 ? 0 : 1]
		self.ref.child("featured").child(category).child(uid).updateChildValues(value)
	}
	
	public func addUpdateFeaturedTutor(tutor: AWTutor,_ completion: @escaping (Error?) -> Void) {
		func bayesianEstimate(C: Double, r: Double, v: Double, m: Double) -> Double {
			return (v / (v + m)) * ((r + Double((m / (v + m)))) * C)
		}
		
		fetchSubjectsTaught(uid: tutor.uid) { (subcategoryList) in
			let avg = subcategoryList.map({$0.rating / 5}).average
			
			let topSubcategory = subcategoryList.sorted {
				return bayesianEstimate(C: avg, r: $0.rating / 5, v: Double($0.numSessions), m: 10) > bayesianEstimate(C: avg, r: $1.rating / 5, v: Double($1.numSessions), m: 10)
				}.first
			
			guard let subjects = topSubcategory?.subjects.split(separator: "$") else { return }
			guard let category = SubjectStore.findCategoryBy(subject: String(subjects[0])) else { return }
			
			let post : [String : Any] = ["img" : tutor.images["image1"]!,"nm" : tutor.name, "p" : tutor.price, "r": tutor.tRating, "rv": tutor.reviews?.count ?? 0, "sbj" : subjects[0], "rg" : tutor.region, "t" : UInt64(NSDate().timeIntervalSince1970 * 1000.0)]
			
			
			self.ref.child("featured").child(category).child(tutor.uid).updateChildValues(post) { (error, _) in
				if let error = error {
					return completion(error)
				}
				return completion(nil)
			}
		}
	}
	
	public func uploadImage(data: Data, number: String,_ completion: @escaping (Error?, String?) -> Void) {
		let userId : String
		userId = (AccountService.shared.currentUserType == .lRegistration) ? Registration.uid : CurrentUser.shared.learner.uid
		
		self.storageRef.child("student-info").child(userId).child("student-profile-pic" + number).putData(data, metadata: nil) { (meta, error) in
			if let error = error {
				return completion(error, nil)
			}
			self.storageRef.child("student-info").child(userId).child("student-profile-pic" + number).downloadURL(completion: { (url, error) in
				if let error = error {
					return completion(error, nil)
				}
				guard let imageUrl = url?.absoluteString else { return }
				return completion(nil, imageUrl)
			})
		}
	}

	public func getCompressedImageDataFor(_ image: UIImage) -> Data? {
		let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: CGFloat(ceil(300 / image.size.width * image.size.height)))))
		imageView.contentMode = .scaleAspectFit
		imageView.image = image
		
		UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, image.scale)
		guard let context = UIGraphicsGetCurrentContext() else {
			print("No context")
			return nil
		}
		imageView.layer.render(in: context)
		guard let scaledImage = UIGraphicsGetImageFromCurrentImageContext() else {
			print("No scaled image")
			return nil
		}
		UIGraphicsEndImageContext()
		guard let dataToUpload = UIImageJPEGRepresentation(scaledImage, 0.6) else {
			print("No data to upload")
			return nil
		}
		return dataToUpload
	}
	
	public func signInLearner(uid: String,_ completion: @escaping (Bool) -> Void) {
		fetchLearner(uid) { (learner) in
			guard let learner = learner else { return completion(false) }
			CurrentUser.shared.learner = learner
			AccountService.shared.loadUser()
			AccountService.shared.currentUserType = .learner
			return completion(true)
		}
	}
	
	public func signInTutor(uid: String,_ completion: @escaping (Bool) -> Void) {
		fetchLearner(uid) { (learner) in
			guard let learner = learner else { return completion(false) }
			CurrentUser.shared.learner = learner
			self.fetchTutor(learner.uid, isQuery: false) { (tutor) in
				guard let tutor = tutor else { return completion(false) }
				CurrentUser.shared.tutor = tutor
				AccountService.shared.loadUser()
				AccountService.shared.currentUserType = .tutor
				Stripe.retrieveConnectAccount(acctId: tutor.acctId, { (error, account) in
					guard let account = account else { return completion(false) }
					CurrentUser.shared.connectAccount = account
					return completion(true)
				})
			}
		}
        
	}
    
    func signInUserOfType(_ type: UserType, uid: String, completion: @escaping (Bool) -> Void) {
        if type == .learner {
            signInLearner(uid: uid) { (success) in
                completion(success)
            }
        } else {
            signInTutor(uid: uid) { (success) in
                completion(success)
            }
        }
    }
    
	deinit {
		print("FirebaseData has De-initialized")
	}
}
