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
import SwiftKeychainWrapper

class CurrentUser {
	
	static let shared = CurrentUser()
	
	var learner : AWLearner!
	var tutor : AWTutor!
}

class AWLearner {
	
	var uid : String = ""
	
	var name	  : String!
	var bio 	  : String!
	var birthday  : String!
	var email 	  : String!
	var phone     : String!
	
	var customer  : String!
	
	var school    : String?
	var languages : [String]?

	var lRating	  : Double!

	var images = ["image1" : "", "image2" : "", "image3" : "", "image4" : ""]
	
	var isTutor : Bool = false
	var hasPayment : Bool = false
	
	init(dictionary: [String:Any]) {
		
		name 		= dictionary["nm"] 		as? String ?? ""
		bio 		= dictionary["bio"] 	as? String ?? ""
		birthday 	= dictionary["bd"] 		as? String ?? ""
		email 	  	= dictionary["em"] 		as? String ?? ""
		school	  	= dictionary["sch"] 	as? String ?? nil
		phone 	  	= dictionary["phn"] 	as? String ?? ""
		languages 	= dictionary["lng"] 	as? [String] ?? nil
		customer 	= dictionary["cus"] 	as? String ?? ""
		
		lRating 		= dictionary["r"] 		as? Double ?? 0.0
	}
}

class AWTutor : AWLearner {
	
	var tBio : String!
	var region : String!
	var policy : String?
	var acctId : String!
	var topSubject : String?
	
	var price : Int!
	var hours : Int!
	var distance : Int!
	var preference : Int!
	var numSessions : Int!
	
	var tRating : Double!
	var earnings : Double!

	var subjects : [String]?
	var selected : [Selected] = []
	var reviews : [TutorReview]?
	
	var hasConnectAccount : Bool = false
	
	override init(dictionary: [String : Any]) {
		super.init(dictionary: dictionary)
		
		policy	 	= dictionary["pol"] as? String ?? ""
		region 		= dictionary["rg"] 	as? String ?? ""
		topSubject 	= dictionary["tp"] 	as? String ?? ""
		tBio		= dictionary["tbio"] as? String ?? ""
		acctId		= dictionary["act"] as? String ?? ""
		
		price 		= dictionary["p"] 	as? Int ?? 0
		hours 		= dictionary["hr"] 	as? Int ?? 0
		distance 	= dictionary["dst"] as? Int ?? 0
		preference 	= dictionary["prf"] as? Int ?? 3
		numSessions = dictionary["nos"] as? Int ?? 0
		
		tRating 	= dictionary["tr"] 	as? Double ?? 5.0
		earnings 	= dictionary["ern"] as? Double ?? 0.0
	}
	
	required init(from decoder: Decoder) throws {
		fatalError("init(from:) has not been implemented")
	}
}

class UserDefaultData {
	
	static let localDataManager = UserDefaultData()
	
	private let defaults = UserDefaults.standard
	
	private init() {
		print("User defaults Initialized")
	}
	
	var hasPaymentMethod : Bool {
		return defaults.bool(forKey: "hasPaymentMethod")
	}
	
	var hasBio : Bool {
		return defaults.bool(forKey: "hasBio")
	}
	var numberOfCards : Int {
		get {
			return defaults.integer(forKey: "numberOfCards")
		}
	}
	var isTutor : Bool {
		get {
			return defaults.bool(forKey: "isTutor")
		}
		set {
			defaults.set(newValue, forKey: "isTutor")
		}
	}
	deinit {
		print("UserData Deninit")
	}
}

class FirebaseData {
	
	static let manager = FirebaseData()
	
	private let ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
	private let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	private let user = Auth.auth().currentUser!
	
	private init() {
		print("firebaser has been initialized")
	}
	
	public func updateValue(node: String, value: [String : Any]) {
		self.ref.child(node).child(user.uid).updateChildValues(value) { (error, reference) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
	
	public func linkEmail(email: String) {
		let password: String? = KeychainWrapper.standard.string(forKey: "emailAccountPassword")
		let credential = EmailAuthProvider.credential(withEmail: email, password: password!)
		user.link(with: credential, completion: { (user, error) in
			if let error = error {
				print(error.localizedDescription)
			}
		})
	}
	
	public func uploadUser(_ completion: @escaping (Error?) -> Void) {
		
		let account : [String : Any] =
			["phn" : Registration.phone,"age" : Registration.age, "em" : Registration.email, "bd" : Registration.dob, "logged" : "", "init" : (Date().timeIntervalSince1970 * 1000)]
		
		let studentInfo : [String : Any] =
			["nm" : Registration.name, "r" : 5.0,
			 "img": ["image1" : Registration.studentImageURL, "image2" : "", "image3" : "", "image4" : ""]
		]
		
		let newUser = ["/account/\(user.uid)/" : account, "/student-info/\(user.uid)/" : studentInfo]
		
		self.ref.root.updateChildValues(newUser) { (error, reference) in
			if let error = error {
				completion(error)
			} else {
				print(reference)
				completion(nil)
			}
		}
	}

	public func removeUserImage(_ number: String) {
		let imageRef = Storage.storage().reference().child("student/\(user.uid)/student-profile-pic\(number)")
		imageRef.delete { (error) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
	
	public func changeMobileNumberRequest(phone: String, completion: @escaping (Error?) -> Void) {
		PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationId, error) in
			if let error = error {
				print(error.localizedDescription)
				completion(error)
			} else {
				UserDefaults.standard.set(verificationId, forKey: "reCredential")
				completion(nil)
			}
		}
	}
	
	public func updateAdditionalQuestions(value: [String : Any], completion: @escaping (Error?) -> Void) {
		self.ref.child("questions").child(user.uid).childByAutoId().updateChildValues(value) { (error, reference) in
			if let error = error {
				completion(error)
			} else {
				completion(nil)
			}
		}
	}
	
	public func fileReport(sessionId: String, reportClass: String, value: [String : Any], completion: @escaping (Error?) -> Void) {
		var values = value
		
		values["timestamp"] = NSDate().timeIntervalSince1970
		self.ref.child("filereport").child(user.uid).child(sessionId).child(reportClass).updateChildValues(values) { (error, reference) in
			if let error = error {
				completion(error)
			} else {
				completion(nil)
			}
		}
	}
	
	public func getLearner(_ uid : String,_ completion: @escaping (AWLearner?) -> Void) {
		
		let group = DispatchGroup()
		
		self.ref.child("account").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			guard let value = snapshot.value as? [String : Any] else {
				print("value 1 error")
				completion(nil)
				return
			}
			self.ref.child("student-info").child(uid).observeSingleEvent(of: .value, with: { (snapshot2) in
				guard let value2 = snapshot2.value as? [String : Any] else {
					print("value2 error")
					completion(nil)
					return
				}
				
				let learnerData = value.merging(value2, uniquingKeysWith: { (first, last) -> Any in
					return last
				})
				
				let learner = AWLearner(dictionary: learnerData)
				learner.uid = uid
				print("start search.")
				group.enter()
				self.ref.child("tutor-info").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
					learner.isTutor = snapshot.exists()
					group.leave()
				})
				print("Out.")
				guard let images = learnerData["img"] as? [String : String] else { return }
				learner.images = images
				
				group.notify(queue: .main) {
					completion(learner)
				}
			})
		})
	}
	
	public func getTutor(_ uid: String, _ completion: @escaping (AWTutor?) -> Void) {
		
		let group = DispatchGroup()
		
		self.ref.child("account").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			guard let value = snapshot.value as? [String : Any] else {
				completion(nil)
				return
			}
			self.ref.child("tutor-info").child(uid).observeSingleEvent(of: .value, with: { (snapshot2) in
				guard let value2 = snapshot2.value as? [String : Any] else {
					completion(nil)
					return
				}
				
				let tutorDict = value.merging(value2, uniquingKeysWith: { (first, last) -> Any in
					return last
				})
				
				let tutor = AWTutor(dictionary: tutorDict)
				tutor.uid = uid
				
				guard let images = tutorDict["img"] as? [String : String] else {
					completion(nil)
					return
				}
				
				tutor.images = images
				group.enter()
				self.loadTutorReviews(uid: uid, { (reviews) in
					print("5")
					if let reviews = reviews {
						tutor.reviews = reviews
					}
					group.leave()
				})
				group.enter()
				self.loadSubjects(uid: uid, { (subcategory) in
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
	
	public func uploadImage(data: Data, number: String,_ completion: @escaping (String?) -> Void) {
		self.storageRef.child("student-info").child(user.uid).child("student-profile-pic" + number).putData(data, metadata: nil) { (meta, error) in
			if error != nil {
				completion(nil)
			} else {
				self.storageRef.child("student-info").child(self.user.uid).child("student-profile-pic" + number).downloadURL(completion: { (url, error) in
					if error != nil {
						completion(nil)
					} else {
						guard let imageUrl = url?.absoluteString else { return }
						completion(imageUrl)
					}
				})
			}
		}
	}
	
	
	func loadTutorReviews(uid : String, _ completion : @escaping ([TutorReview]?) -> Void) {
		
		var reviews : [TutorReview] = []
		
		self.ref?.child("review").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			
			guard let snap = snapshot.children.allObjects as? [DataSnapshot] else { return }
			
			for child in snap {
				
				guard let value = child.value as? [String : Any] else { return }
				
				var review = TutorReview(dictionary: value)
				review.sessionId = child.key
				
				reviews.append(review)
			}
			completion(reviews)
		})
	}
	
	func loadSubjects(uid: String, _ completion: @escaping ([TutorSubcategory]?) -> Void) {
		
		var subcategories : [TutorSubcategory] = []
		
		self.ref?.child("subject").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			
			if let snap = snapshot.children.allObjects as? [DataSnapshot] {
				
				for child in snap {
					
					guard let value = child.value as? [String : Any] else { return }
					
					var subcategory = TutorSubcategory(dictionary: value)
					subcategory.subcategory = child.key
					subcategories.append(subcategory)
				}
			}
			completion(subcategories)
		})
	}
	
	public func getCompressedImageDataFor(_ image: UIImage) -> Data? {
		let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: CGFloat(ceil(200 / image.size.width * image.size.height)))))
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
		guard let dataToUpload = UIImageJPEGRepresentation(scaledImage, 0.5) else {
			print("No data to upload")
			return nil
		}
		//		profileImageData = dataToUpload
		return dataToUpload
	}
	deinit {
		print("FirebaseData has De-initialized")
	}
}

