//
//  SignInHandler.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import FirebaseDatabase
import FirebaseStorage

class SignInHandler {
	
//	private let ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
//	private let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
//	private let user = Auth.auth().currentUser!
//	
//	let learner = LearnerData.userData
//	
//	init(_ completion: @escaping (Error?) -> Void) {
//		
//		getAccountData()
//		checkIsTutor()
//		getLearnerData { (error) in
//			if let error = error {
//				completion(error)
//			} else {
//				completion(nil)
//			}
//		}
//	}
//	
//	public func getAccountData() {
//		self.ref.child("account").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
//			let value = snapshot.value as? NSDictionary
//			
//			self.learner.phone			= value?["phn"	] as? String ?? ""
//			self.learner.email          = value?["em"   ] as? String ?? ""
//			self.learner.birthday	    = value?["bd"	] as? String ?? ""
//			
//		})
//	}
//	
//	public func getLearnerData(completion: @escaping (Error?) -> Void) {
//		
//		self.ref.child("student-info").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
//				let value = snapshot.value as? NSDictionary
//			
//				self.learner.name			= value?["nm"			]   as? String ?? ""
//				self.learner.bio          	= value?["bio"          ]   as? String ?? ""
//				self.learner.school         = value?["sch"       	]   as? String ?? ""
//				self.learner.languages     	= value?["lng"   		]   as? [String] ?? []
//				self.learner.customer 		= value?["cus" 			]	as?	String ?? ""
//				self.learner.rating			= value?["r"			]	as? Double ?? 5.0
//			
//			print("Grabbing image urls...")
//			
//			self.grabImageUrls {
//				print("Done grabbing image urls.")
//				completion(nil)
//			}
//		}) { (error) in
//			completion(error)
//		}
//	}

//	private func grabImageUrls(completion: @escaping () -> Void) {
//		self.ref.child("student-info").child(".uid").child("img").observeSingleEvent(of: .value) { (snapshot) in
//
//			let value = snapshot.value as? NSDictionary
//
//			self.downloadImage((value?["image1"] as? String) ?? "", "1")
//			self.downloadImage((value?["image2"] as? String) ?? "", "2")
//			self.downloadImage((value?["image3"] as? String) ?? "", "3")
//			self.downloadImage((value?["image4"] as? String) ?? "", "4")
//
//			completion()
//		}
//	}
	
//	private func downloadImage(_ imageUrl : String, _ number: String) {
//		print("downloading Image\(number)...")
//
//		if imageUrl == "" {
//
//			inputDefaultImage(number: number)
//
//			return
//		}
//
//		let storage = Storage.storage().reference(forURL: imageUrl)
//
//		storage.getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
//
//			if let error = error {
//				print(error)
//			} else {
//
//				let image : UIImage! = UIImage(data: data!)
//
//				LocalImageCache.localImageManager.storeImageLocally(image: image.circleMasked!, number: number)
//
//				LearnerData.userData.images["image\(number)"] = imageUrl
//			}
//		}
//		print("image\(number) downloaded.")
//	}
	
//	private func inputDefaultImage(number: String) {
//		
//		LocalImageCache.localImageManager.storeImageLocally(image: #imageLiteral(resourceName: "registration-image-placeholder"), number: number)
//		
//		LearnerData.userData.images["image\(number)"] = ""
//	}
	
//	private func checkIsTutor() {
//
//		self.ref.child("tutor-info").child("user.uid").observeSingleEvent(of: .value, with: { (snapshot) in
//
//			if snapshot.exists() {
//				//do things related to being a tutor
//				self.learner.isTutor = true
//				UserDefaultData.localDataManager.isTutor = true
//			} else {
//				self.learner.isTutor = false
//				//do things related to not being a tutor
//			}
//		})
//	}
}
