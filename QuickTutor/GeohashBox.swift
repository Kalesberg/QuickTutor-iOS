//
//  GeohashBox.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

struct GeohashBox {
	let hash : String
	
	let north : Double
	let south : Double
	let west  : Double
	let east  : Double
	
	var location : (latitude: Double, longitude: Double) {
		let latitude  = (self.north + self.south) / 2
		let longitude = (self.east + self.west)   / 2
		return (latitude: latitude, longitude: longitude)
	}
	
	var size : (latitude: Double, longitude: Double) {
		let latitude = north - south
		let longitude = east - west
		return (latitude: latitude, longitude: longitude)
	}
}
