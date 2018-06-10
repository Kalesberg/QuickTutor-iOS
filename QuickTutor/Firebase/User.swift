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
	
	public func updateTutorVisibility(uid: String, status: Int) {
		self.ref.child("tutor-info").child(uid).updateChildValues(["h" : status])
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
	public func getProfileImagesFor(uid: String,_ competion: @escaping ([String]?) -> Void) {
		self.ref.child("tutor-info").child(uid).child("img").observeSingleEvent(of: .value) { (snapshot) in
			guard let value = snapshot.value as? [String : String] else { return }
			competion(value.values.filter({$0 != ""}))
		}
	}
	
	public func fileReport(sessionId: String, reportStatus: Int, value: [String : Any], completion: @escaping (Error?) -> Void) {
        self.ref.child("filereport").child(user.uid).child(sessionId).updateChildValues(value) { (error, reference) in
            if let error = error {
                completion(error)
			} else {
				self.ref.child("sessions").child(sessionId).updateChildValues(["reported" : reportStatus])
                completion(nil)
            }
        }
    }

	public func updateTutorPreferences(uid: String, price: Int, distance: Int, preference: Int,_ completion: @escaping (Error?) -> Void) {
		let post : [String: Any] = ["p" : price, "dst" : distance, "prf": preference]
		self.ref.child("tutor-info").child(uid).updateChildValues(post) { (error, _) in
			if let error = error {
				completion(error)
			} else {
				completion(nil)
			}
		}
	}
	
	private func fetchSessions(uid: String, type: String,_ completion: @escaping ([String]?) -> Void) {
		self.ref.child("userSessions").child(uid).child(type).observeSingleEvent(of: .value) { (snapshot) in
			guard let value = snapshot.value as? [String : Any] else {
				completion(nil)
				return
			}
			completion(value.compactMap({$0.key}))
		}
	}
	
	public func getUserSessions(uid: String, type: String,_ completion: @escaping ([UserSession]) -> Void) {
		var sessions : [UserSession] = []
		let group = DispatchGroup()
		//add a check to see if they have reported the session already.
		fetchSessions(uid: uid, type: type) { (sessionIds) in
			if let sessionIds = sessionIds {
				print("here.")
				for id in sessionIds {
					group.enter()
					self.ref.child("sessions").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
						guard let value = snapshot.value as? [String : Any] else {
							group.leave()
							print("left.")
							return
						}
						var session = UserSession(dictionary: value)
						session.id = id
						//this will be used to check for 'pending' or 'filed' reports later. For now it just dumps the current session.
						if type == "learner" && (session.reportStatus == 1 || session.reportStatus == 3) {
							print("return")
							return
						}
						if type == "tutor" && (session.reportStatus == 2 || session.reportStatus == 3) {
							print("return")
							return
						}
						group.enter()
						self.ref.child("student-info").child(session.otherId).child("nm").observeSingleEvent(of: .value, with: { (snapshot) in
							if let name = snapshot.value as? String {
								session.name = name
							}
							group.leave()
						})
						group.enter()
						self.ref.child("student-info").child(session.otherId).child("img").child("image1").observeSingleEvent(of: .value, with: { (snapshot) in
							if let imageURL = snapshot.value as? String {
								session.imageURl = imageURL
							}
							sessions.append(session)
							group.leave()
						})
						group.leave()
					})
				}
				group.notify(queue: .main, execute: {
					print("here.")
					completion(sessions)
				})
			} else {
				completion([])
			}
		}
	}

    public func getLearner(_ uid : String,_ completion: @escaping (AWLearner?) -> Void) {
        
        let group = DispatchGroup()
        
        self.ref.child("account").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String : Any] else {
                completion(nil)
                return
            }
            self.ref.child("student-info").child(uid).observeSingleEvent(of: .value, with: { (snapshot2) in
                guard let value2 = snapshot2.value as? [String : Any] else {
                    completion(nil)
                    return
                }
                
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
                self.getLearnerConnections(uid: uid, { (connections) in
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
    
	public func getTutor(_ uid: String, isQuery: Bool,_ completion: @escaping (AWTutor?) -> Void) {
        
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
				
				if isQuery && (tutorDict["h"] as? Int == 1) {
					completion(nil)
					return
				}

                guard let images = tutorDict["img"] as? [String : String] else {
                    print("Couldn't find images: ", uid)
                    completion(nil)
                    return
                }
                tutor.images = images

                self.getTutorLocation(uid: uid, { (location) in
                    if let location = location {
                        tutor.location = location
                    }
                })

                group.enter()
                self.loadTutorReviews(uid: uid, { (reviews) in
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
    
    public func uploadImage(data: Data, number: String,_ completion: @escaping (Error?, String?) -> Void) {
        self.storageRef.child("student-info").child(user.uid).child("student-profile-pic" + number).putData(data, metadata: nil) { (meta, error) in
            if let error = error {
                completion(error, nil)
            } else {
                self.storageRef.child("student-info").child(self.user.uid).child("student-profile-pic" + number).downloadURL(completion: { (url, error) in
                    if let error = error {
                        completion(error,nil)
                    } else {
                        guard let imageUrl = url?.absoluteString else { return }
                        completion(nil, imageUrl)
                    }
                })
            }
        }
    }
    
    public func getTutorLocation(uid: String,_ completion: @escaping (TutorLocation1?) -> Void) {
        self.ref?.child("tutor_loc").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                guard let value = snapshot.value as? [String : Any] else { return }
                let tutorLocation = TutorLocation1(dictionary: value)
                completion(tutorLocation)
            } else {
                completion(nil)
            }
        })
    }
    
    public func loadTutorReviews(uid : String, _ completion : @escaping ([TutorReview]?) -> Void) {
        var reviews : [TutorReview] = []
        self.ref?.child("review").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snap = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for child in snap {
                guard let value = child.value as? [String : Any] else { continue }
                
                var review = TutorReview(dictionary: value)
                review.sessionId = child.key
                reviews.append(review)
            }
            completion(reviews)
        })
    }
    
    public func loadSubjects(uid: String, _ completion: @escaping ([TutorSubcategory]?) -> Void) {
        
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
            completion(subcategories)
        })
    }
	
    public func getLearnerConnections(uid: String, _ completion: @escaping ([String]?) -> Void) {
        var uids = [String]()
        self.ref.child("connections").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.children.allObjects as? [DataSnapshot] {
                for child in snap {
                    uids.append(child.key)
                }
            }
            completion(uids)
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
        guard let dataToUpload = UIImageJPEGRepresentation(scaledImage, 0.3) else {
            print("No data to upload")
            return nil
        }
        return dataToUpload
    }
    
    public func removeTutorAccount(uid: String, reason: String, subcategory: [String], message: String, _ completion: @escaping (Error?) -> Void) {
        
        var childNodes : [String : Any] = [:]
        
        childNodes["/connections/\(uid)"] = NSNull()
        childNodes["/conversations/\(uid)"] = NSNull()
        childNodes["/featured/\(uid)"] = NSNull()
        childNodes["/readReceipts/\(uid)"] = NSNull()
        childNodes["/review/\(uid)"] = NSNull()
        childNodes["/subject/\(uid)"] = NSNull()
        childNodes["/tutor-info/\(uid)"] = NSNull()
        childNodes["/tutor_loc/\(uid)"] = NSNull()
        childNodes["/userSessions/\(uid)"] = NSNull()
        childNodes["/deleted/\(uid)"] = ["reason" : reason, "message": message, "type" : "both"]
        
        for subcat in subcategory {
            childNodes["/subcategory/\(subcat)/\(uid)"] = NSNull()
        }
        
        self.ref.root.updateChildValues(childNodes) { (error, _) in
            if let error = error {
                completion(error)
            } else {
                UserDefaults.standard.set(true, forKey: "showHomePage")
                completion(nil)
            }
        }
    }
	
    public func removeBothAccounts(uid: String, reason: String, subcategory: [String], message: String, _ completion: @escaping (Error?) -> Void) {
        
        let group = DispatchGroup()
        
        var childNodes = [String : Any]()
        
        childNodes["/account/\(uid)"] = NSNull()
        childNodes["/connections/\(uid)"] = NSNull()
        childNodes["/featured/\(uid)"] = NSNull()
        childNodes["/notificationPreferences/\(uid)"] = NSNull()
        childNodes["/readReceipts/\(uid)"] = NSNull()
        childNodes["/review/\(uid)"] = NSNull()
        childNodes["/student-info/\(uid)"] = NSNull()
        childNodes["/subject/\(uid)"] = NSNull()
        childNodes["/tutor-info/\(uid)"] = NSNull()
        childNodes["/tutor_loc/\(uid)"] = NSNull()
        childNodes["/userSessions/\(uid)"] = NSNull()
        childNodes["/deleted/\(uid)"] = ["reason" : reason, "message": message, "type" : "both"]
        
        for subcat in subcategory {
            childNodes["/subcategory/\(subcat)/\(uid)"] = NSNull()
        }
		
        for imageURL in CurrentUser.shared.learner.images {
            if imageURL.value == "" { continue }
			group.enter()
            Storage.storage().reference(forURL: imageURL.value).delete { (error) in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.ref.root.updateChildValues(childNodes) { (error, _) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(error)
                } else {
                    UserDefaults.standard.set(true, forKey: "showHomePage")
                    completion(nil)
                }
            }
        }
    }
    
    public func removeLearnerAccount(uid: String, reason: String,_ completion: @escaping (Error?) -> Void) {
        var childNodes = [String : Any]()
        
        childNodes["/student-info/\(uid)"] = NSNull()
        childNodes["/account/\(uid)"] = NSNull()
        childNodes["/deleted/\(uid)"] = ["reason" : reason,"email": CurrentUser.shared.learner.email, "type" : "learner", "time": NSDate().timeIntervalSince1970]

        self.ref.root.updateChildValues(childNodes) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
            } else {
                for imageURL in CurrentUser.shared.learner.images {
                    if imageURL.value == "" { continue }
                    Storage.storage().reference(forURL: imageURL.value).delete { (error) in
                        if let error = error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    public func signInLearner(uid: String,_ completion: @escaping (Bool) -> Void) {
        getLearner(uid) { (learner) in
            if let learner = learner {
                CurrentUser.shared.learner = learner
                AccountService.shared.loadUser()
                AccountService.shared.currentUserType = .learner
                Stripe.retrieveCustomer(cusID: learner.customer) { (customer, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)
                    } else if let customer = customer {
                        learner.hasPayment = (customer.sources.count > 0)
                        completion(true)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    public func signInTutor(uid: String,_ completion: @escaping (Bool) -> Void) {
        getLearner(uid) { (learner) in
            if let learner = learner {
                CurrentUser.shared.learner = learner
				self.getTutor(learner.uid, isQuery: false) { (tutor) in
                    if let tutor = tutor {
                        CurrentUser.shared.tutor = tutor
                        AccountService.shared.loadUser()
                        AccountService.shared.currentUserType = .tutor
                        Stripe.retrieveConnectAccount(acctId: tutor.acctId, { (account) in
                            if let account = account {
                                CurrentUser.shared.connectAccount = account
                                completion(true)
                            } else {
                                completion(false)
                            }
                        })
                    } else {
                        completion(false)
                        
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    deinit {
        print("FirebaseData has De-initialized")
    }
}


