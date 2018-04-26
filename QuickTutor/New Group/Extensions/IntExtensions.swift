//
//  IntExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

extension Int {

	func priceFormat() -> String {
		return "$\(self)/hr"
	}
	
	func preferenceNormalization() -> String {
		if self == 3 {
			return " - Will tutor Online or In-Person\n\n"
		} else if self == 2 {
			return " - Will tutor In-Person\n\n"
		} else if self == 1 {
			return " - Will tutor Online \n\n"
		} else {
			return " - Currently unavailable\n\n"
		}
	}
	
	func distancePreference(_ preference: Int) -> String {
		if preference == 3 || preference == 2 {
			return " - Will travel up to \(self) miles\n\n"
		} else {
			return " - Unable to travel.\n\n"
		}
	}
}
