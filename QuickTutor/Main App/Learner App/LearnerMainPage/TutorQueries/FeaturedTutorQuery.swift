//
//  FeaturedTutorQuery.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import CoreLocation
import Firebase
import Foundation

class QueryData {
    static let shared = QueryData()
    private var ref: DatabaseReference? = Database.database().reference(fromURL: Constants.DATABASE_URL)

	func queryFeaturedTutors(categories: [Category], _ completion: @escaping ([Category: [AWTutor]]?) -> Void) {
        var uids = [Category: [AWTutor]]()
        let group = DispatchGroup()

        for category in categories {
            uids[category] = []
            let categoryString = category.subcategory.fileToRead
            group.enter()
            ref?.child("featured").child(categoryString).queryOrderedByKey().queryLimited(toFirst: 5).observeSingleEvent(of: .value, with: { snapshot in
                for snap in snapshot.children {
                    guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid! else { continue }
                    group.enter()
                    FirebaseData.manager.fetchFeaturedTutor(child.key, category: category.subcategory.fileToRead, { tutor in
                        if let tutor = tutor {
                            if tutor.uid != Auth.auth().currentUser?.uid {
                                uids[category]!.append(tutor)
                            }
                        }
                        group.leave()
                    })
                }
                group.leave()
            })
        }
        group.notify(queue: .main) {
            completion(uids)
        }
    }
	
	func queryAWFeaturedTutorsCard(featuredTutors: [AWTutor],_ completion: @escaping ([AWTutor]?) -> Void) {
		var tutors = [AWTutor]()
		let group = DispatchGroup()
		
		for (index, tutor) in featuredTutors.enumerated() {
			group.enter()
			FirebaseData.manager.fetchTutor(tutor.uid, isQuery: false) { (tutor) in
				if let tutor = tutor {
                    tutor.featuredDetails = FeaturedDetails(subject: featuredTutors[index].featuredSubject ?? "", price: featuredTutors[index].price)
					tutors.append(tutor)
				}
				group.leave()
			}
		}
		group.notify(queue: .main) {
			completion(tutors)
		}
	}
	
    func queryAWTutorByCategory(category: CategoryNew, lastKnownKey: String?, limit: UInt,_ completion: @escaping ([AWTutor]?) -> Void) {
        var tutors = [AWTutor]()
        let group = DispatchGroup()
        let query: DatabaseQuery?

        if let lastKnownKey = lastKnownKey {
            query = ref?.child("featured").child(category.name.lowercased()).queryOrderedByKey().queryStarting(atValue: lastKnownKey).queryLimited(toFirst: limit)
        } else {
            query = ref?.child("featured").child(category.name.lowercased()).queryOrderedByKey().queryLimited(toFirst: limit)
        }

        query?.observeSingleEvent(of: .value) { snapshot in
            for snap in snapshot.children {
                guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid! else { continue }
                group.enter()
                FirebaseData.manager.fetchFeaturedTutor(child.key, category: category.name.lowercased(), { tutor in
                    if let tutor = tutor {
                            tutors.append(tutor)
                    }
                    group.leave()
                })
            }
            group.notify(queue: .main) {
                if lastKnownKey != nil {
                    tutors.removeFirst()
                }
                completion(tutors)
            }
        }
    }

	func queryAWTutorUidsByCategory(category: Category, lastKnownKey: String?, limit: UInt, _ completion: @escaping ([AWTutor]?) -> Void) {
		var tutors = [AWTutor]()
		let query: DatabaseQuery!
		
		if let lastKnownKey = lastKnownKey {
			query = ref?.child("featured").child(category.subcategory.fileToRead).queryOrderedByKey().queryStarting(atValue: lastKnownKey).queryLimited(toFirst: limit)
		} else {
			query = ref?.child("featured").child(category.subcategory.fileToRead).queryOrderedByKey().queryLimited(toFirst: limit)
		}
		
		query.observeSingleEvent(of: .value) { snapshot in
			for snap in snapshot.children {
				guard let child = snap as? DataSnapshot,
					  let value = child.value as? [String : Any],
					  child.key != CurrentUser.shared.learner.uid!
				else {
					continue
				}
				let featuredTutor = AWTutor(dictionary: value)
				featuredTutor.uid = child.key
				tutors.append(featuredTutor)
			}
			if lastKnownKey != nil {
				tutors.removeFirst()
			}
			completion(tutors)
		}
	}
	
    func queryAWTutorBySubject(subcategory: String, subject: String, _ completion: @escaping ([AWTutor]?) -> Void) {
        var tutors = [AWTutor]()
        let group = DispatchGroup()
        let formattedSubject = subject.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "#", with: "<").replacingOccurrences(of: ".", with: ">")

        ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: formattedSubject).queryEqual(toValue: formattedSubject).observeSingleEvent(of: .value, with: { snapshot in
            for snap in snapshot.children {
                guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid else { continue }
                group.enter()
                FirebaseData.manager.fetchTutor(child.key, isQuery: true, { tutor in
                    if let tutor = tutor {
                        tutors.append(tutor)
                    }
                    group.leave()
                })
            }
            group.notify(queue: .main) {
                completion(tutors)
            }
        })
    }

    func queryAWTutorBySubcategory(subcategory: String, _ completion: @escaping ([AWTutor]?) -> Void) {
        var tutors = [AWTutor]()
        let group = DispatchGroup()

        ref?.child("subcategory").child(subcategory.lowercased()).queryOrdered(byChild: "r").queryStarting(atValue: 3.0).queryLimited(toFirst: 50).observeSingleEvent(of: .value) { snapshot in

            for snap in snapshot.children {
                guard let child = snap as? DataSnapshot, child.key != CurrentUser.shared.learner.uid else { continue }
                group.enter()
                FirebaseData.manager.fetchTutor(child.key, isQuery: true, { tutor in
                    if let tutor = tutor {
                        tutors.append(tutor)
                    }
                    group.leave()
                })
            }
            group.notify(queue: .main) {
                completion(tutors)
            }
        }
    }
}
