//
//  TutorSignIn.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import Firebase
import FirebaseDatabase
import FirebaseStorage

class TutorSignIn {
	
	private let ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
	private let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	private let user = Auth.auth().currentUser!
	
	let tutor = TutorData.shared
	
	init(_ completion: @escaping (Error?) -> Void) {
		
		getAccountData()
		
		getTutorSubjects { (subjects) in
			if let subjects = subjects {
				print(subjects)
				self.tutor.subjects = subjects
			}
		}
		QueryData.shared.loadReviews(uid: user.uid) { (reviews) in
			if let reviews = reviews {
				self.tutor.reviews = reviews
			}
		}

		getTutorData { (error) in
			if let error = error {
				completion(error)
			} else {
				completion(nil)
			}
		}
	}
	
	public func getAccountData() {
		
		self.ref.child("account").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
			
			let value = snapshot.value as? NSDictionary
			
			self.tutor.phone		= value?["phn"	] as? String ?? ""
			self.tutor.email        = value?["em"   ] as? String ?? ""
			self.tutor.birthday	    = value?["bd"	] as? String ?? ""

		})
	}
	
	public func getTutorData(completion: @escaping (Error?) -> Void) {
		
		self.ref.child("tutor-info").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
			
			if let value = snapshot.value as? NSDictionary {
				
				self.tutor.name	       = value["nm" ]   as? String ?? ""
				self.tutor.bio         = value["bio"]   as? String ?? ""
				self.tutor.school      = value["sch"]   as? String ?? ""
				self.tutor.account     = value["tok"]	 as? String ?? ""
				self.tutor.policy 	   = value["pol"]	 as? String ?? ""
				self.tutor.region      = value["rg" ]   as? String ?? ""
				self.tutor.topSubject  = value["tp"]   as? String ?? ""
				
				self.tutor.distance	   = value["dst" ]   as? Int ?? 5
				self.tutor.price	   = value["p"]   as? Int ?? 5
				self.tutor.numSessions = value["nos"]   as? Int ?? 0
				self.tutor.preference  = value["prf"]	 as? Int ?? 3
				self.tutor.hours	   = value["hr"] as? Int ?? 0
				
				self.tutor.rating 	   = value["r"]   as? Double ?? 0
				self.tutor.earnings    = value["ern"]   as? Double ?? 0.0
				
				self.tutor.languages   = value["lng"]   as? [String] ?? []
				
				self.grabImageUrls {
					print("Done grabbing image urls.")
					completion(nil)
				}
			} else {
				print("Data snapShot error ")
			}
		}) { (error) in
			completion(error)
		}
	}
	
	private func getTutorSubjects(_ completion: @escaping ([String]?) -> Void) {
		
		QueryData.shared.loadSubjects(uid: user.uid) { (subcategory) in
			
			var selected : [Selected] = []
			var subjects : [String] = []
			
			if let subcategory = subcategory {
				
				for subject in subcategory {
					let this = subject.subjects.split(separator: "$")
					
					for i in this {
						selected.append(Selected(path: "\(subject.subcategory)", subject: String(i)))
						subjects.append(String(i))
					}
				}
			}
			self.tutor.selected = selected
			completion(subjects)
		}
	}
	
	private func grabImageUrls(completion: @escaping () -> Void) {
		self.ref.child("tutor-info").child(user.uid).child("img").observeSingleEvent(of: .value) { (snapshot) in
			
			if let value = snapshot.value as? NSDictionary {
			
				self.downloadImage((value["image1"] as? String) ?? "", "1")
				self.downloadImage((value["image2"] as? String) ?? "", "2")
				self.downloadImage((value["image3"] as? String) ?? "", "3")
				self.downloadImage((value["image4"] as? String) ?? "", "4")
			
				completion()
			} else {
				print("Error grabbing imageURLS")
			}
		}
	}
	
	private func downloadImage(_ imageUrl : String, _ number: String) {
		print("downloading Image\(number)...")
		
		if imageUrl == "" {
			
			inputDefaultImage(number: number)
			
			return
		}
		
		let storage = Storage.storage().reference(forURL: imageUrl)
		
		storage.getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
			
			if let error = error {
				print(error)
				print("Storage Error")
			} else {
				
				let image : UIImage! = UIImage(data: data!)
				
				LocalImageCache.localImageManager.storeImageLocally(image: image.circleMasked!, number: number)
				
				LearnerData.userData.images["image\(number)"] = imageUrl
			}
		}
		print("image\(number) downloaded.")
	}
	
	private func inputDefaultImage(number: String) {
		
		LocalImageCache.localImageManager.storeImageLocally(image: #imageLiteral(resourceName: "registration-image-placeholder"), number: number)
		
		LearnerData.userData.images["image\(number)"] = ""
	}
}
