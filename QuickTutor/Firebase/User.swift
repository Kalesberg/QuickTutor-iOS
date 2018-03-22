//
//  UploadUser.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

// TODO: add didSet functions and init() methods to classes to update the UI

import Firebase
import Stripe
import SwiftKeychainWrapper

class LearnerData {
	
	static let userData = LearnerData()
	
	var firstName : String!
	var lastName : String!
	var bio : String!
	var birthday : String!
	var email : String!
	var school : String!
	var phone : String!
	var age : String!
	var languages : [String]!
	var address : String!
	var customer : String!
	var images = ["image1" : "", "image2" : "", "image3" : "", "image4" : ""]
	
}

class LocalImageCache {
	
	static let localImageManager = LocalImageCache()
	
	var image1 : UIImage! {
		return getImage(number: "1")
	}
	var image2 : UIImage! {
		print("set image2")
		return getImage(number: "2")
	}
	var image3 : UIImage! {
		print("set image3")
		return getImage(number: "3")
	}
	var image4 : UIImage! {
		print("set image4")
		return getImage(number: "4")
	}
	
	func getDocumentsDirectory() -> URL{
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
	func storeImageLocally(image: UIImage, number: String) {
		if let data = UIImagePNGRepresentation(image) {
			
			let filename = getDocumentsDirectory().appendingPathComponent("image\(number).png")
			do {
				try data.write(to: filename)
			} catch {
				print("error with image")
			}
		}
	}
	func updateImageStored(image: UIImage, number: String) {
		if let data = UIImagePNGRepresentation(image) {
			let filename = getDocumentsDirectory().appendingPathComponent("image\(number).png")
			do {
				try data.write(to: filename)
				FirebaseData.manager.uploadUserImage(image: image.circleMasked!, number: number, completion: { (imageUrl) in
					if let imageUrl = imageUrl {
						LearnerData.userData.images["image\(number)"] = imageUrl
						FirebaseData.manager.updateValue(value: ["img" : LearnerData.userData.images])
					} else {
						print("error")
					}
				})
			} catch {
				print("error with image")
			}
		}
	}
	
	func getImage(number : String) -> UIImage? {
		let fileManager = FileManager.default
		let filename = getDocumentsDirectory().appendingPathComponent("image\(number).png")
		
		if fileManager.fileExists(atPath: filename.path) {
			return UIImage(contentsOfFile: filename.path)
		} else {
			return UIImage(imageLiteralResourceName: "registration-image-placeholder")
		}
	}
	
	func removeImage(number : String) {
		if let data = UIImagePNGRepresentation(#imageLiteral(resourceName: "registration-image-placeholder")) {
			let filename = getDocumentsDirectory().appendingPathComponent("image\(number).png")
			do {
				try data.write(to: filename)
				LearnerData.userData.images["image\(number)"] = ""
				FirebaseData.manager.updateValue(value: ["image" : LearnerData.userData.images])
				FirebaseData.manager.removeUserImage(number)
			} catch {
				print("error with image")
			}
		}
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

extension UserDefaultData /* Functions */ {
	
	func addCard() {
		defaults.set(numberOfCards + 1, forKey:"numberOfCards")
		defaults.set(true, forKey: "hasPaymentMethod")
	}
	
	func deleteCard() {
		defaults.set(numberOfCards - 1, forKey: "numberOfCards")
		if defaults.integer(forKey: "numberOfCards") == 0 {
			defaults.set(false, forKey: "hasPaymentMethod")
		}
	}
	
	func updateValue(for key: String, value: Any) {
		defaults.set(value, forKey: key)
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
	
	public func updateValue(value: [String : Any]) {
		self.ref.child("student").child(user.uid).updateChildValues(value) { (error, reference) in
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
	
	public func initLearner(completion: @escaping (Bool) -> ()) {
		let post : [String : Any] =
			["fn" : Registration.firstName!,
			 "ln" : Registration.lastName!,
			 "bd" : Registration.dob!,
			 "age" : Registration.age,
			 "em": Registration.email,
			 "phn" : Registration.phone,
			 "bio" : "",
			 "sch" : "",
			 "lng" : [""],
			 "addr" : "",
			 "lat" : 0.0,
			 "long" : 0.0,
			 "img": ["image1" : Registration.studentImageURL, "image2" : "", "image3" : "", "image4" : ""]]
		
		self.ref.child("student").child(user.uid).setValue(post) { (error, databaseRef) in
			if let error = error {
				print(error.localizedDescription)
				completion(false)
			} else {
				print("User is in the database!")
				completion(true)
			}
		}
	}
	
	public func uploadUserImage(image: UIImage, number: String, completion: @escaping (_ imageUrl: String?) -> Void) {
		let path = "student/\(user.uid)/student-profile-pic\(number)"
		if let uploadData = UIImageJPEGRepresentation(image, 0.5) {
			storageRef.child(path).putData(uploadData, metadata: nil, completion: { (meta, error) in
				if let error = error {
					print(error.localizedDescription)
					completion(nil)
				} else {
					let imageURL = (meta?.downloadURL()?.absoluteString)!
					completion(imageURL)
				}
			})
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
	
	deinit {
		print("FirebaseData has De-initialized")
	}
}

