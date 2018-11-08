//
//  FeaturedTutorCount.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

struct FeaturedTutorCount {
	let academics : Int
	let arts : Int
	let auto : Int
	let business : Int
	let health : Int
	let language : Int
	let lifestyle : Int
	let outdoors : Int
	let remedial : Int
	let sports : Int
	let tech : Int
	let trades : Int
	
	init(dictionary: [String : Any]) {
		self.academics = dictionary["academics"] as! Int
		self.arts = dictionary["arts"] as! Int
		self.auto = dictionary["auto"] as! Int
		self.business = dictionary["business"] as! Int
		self.health = dictionary["health"] as! Int
		self.language = dictionary["language"] as! Int
		self.lifestyle = dictionary["lifestyle"] as! Int
		self.outdoors = dictionary["outdoors"] as! Int
		self.remedial = dictionary["remedial"] as! Int
		self.sports = dictionary["sports"] as! Int
		self.tech = dictionary["tech"] as! Int
		self.trades = dictionary["trades"] as! Int
	}
}
