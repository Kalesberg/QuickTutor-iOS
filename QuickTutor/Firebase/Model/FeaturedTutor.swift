//
//  FeaturedTutor.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

struct FeaturedTutor {
	var uid: String = ""
	
	let name: String
	let price: Int
	let imageUrl: String
	let region: String
	let rating: Double
	let reviews: Int
	let subject: String
	let isHidden: Int
	
	init(dictionary: [String: Any]) {
		price = dictionary["p"] as? Int ?? 0
		imageUrl = dictionary["img"] as? String ?? ""
		region = dictionary["rg"] as? String ?? ""
		rating = dictionary["r"] as? Double ?? 5.0
		reviews = dictionary["rv"] as? Int ?? 0
		subject = dictionary["sbj"] as? String ?? ""
		isHidden = dictionary["h"] as? Int ?? 0
		
		if let nameSplit = (dictionary["nm"] as? String)?.split(separator: " ") {
			name = "\(nameSplit[0]) \(String(nameSplit[1]).prefix(1))."
		} else {
			name = ""
		}
	}
}
