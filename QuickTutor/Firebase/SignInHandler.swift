//
//  SignInHandler.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase

class SignInHandler {
	
	static let manager = SignInHandler()
	
	private let ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
	
	private let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	
	private let user = Auth.auth().currentUser!
	
	public func getUserData(completion: @escaping (_ error: Error?) -> Void) {
		print("Referencing Database...")
		self.ref.child("student").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
				let value = snapshot.value as? NSDictionary
				let user = LearnerData.userData
				
				user.firstName     	= value?["fn"        	]   as? String ?? ""
				user.lastName       = value?["ln"        	]   as? String ?? ""
				user.age            = value?["age"          ]   as? String ?? ""
				user.bio          	= value?["bio"          ]   as? String ?? ""
				user.birthday       = value?["bd"     		]   as? String ?? ""
				user.school         = value?["sch"       	]   as? String ?? ""
				user.email         	= value?["em"        	]   as? String ?? ""
				user.phone         	= value?["phn"        	]   as? String ?? ""
				user.address       	= value?["adr"      	]   as? String ?? ""
				user.languages     	= value?["lng"   		]   as? [String] ?? [""]
				user.customer 		= value?["cus" 			]	as?	String ?? ""
				
				print("Grabbing image urls...")
				self.grabImageUrls {
					print("Done grabbing image urls.")
					completion(nil)
			}
		}) { (error) in
			completion(error)
		}
	}
	
	private func grabImageUrls(completion: @escaping () -> Void) {
		self.ref.child("student").child(user.uid).child("img").observeSingleEvent(of: .value) { (snapshot) in
			
			let value = snapshot.value as? NSDictionary
			
			self.downloadImage((value?["image1"] as? String) ?? "", "1")
			self.downloadImage((value?["image2"] as? String) ?? "", "2")
			self.downloadImage((value?["image3"] as? String) ?? "", "3")
			self.downloadImage((value?["image4"] as? String) ?? "", "4")
			
			completion()
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
