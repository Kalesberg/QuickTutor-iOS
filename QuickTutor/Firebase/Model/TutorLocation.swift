//
//  TutorLocation.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import CoreLocation

struct TutorLocation {
	var geohash: String?
	var location: CLLocation? = nil
	init(dictionary: [String: Any]) {
		geohash = dictionary["g"] as? String ?? nil
		guard let locationArray = dictionary["l"] as? [Double] else { return }
		location = CLLocation(latitude: locationArray[0], longitude: locationArray[1])
	}
}
