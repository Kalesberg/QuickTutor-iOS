//
//  DateExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

extension Date {
	func daySuffix() -> String {
		let calendar = Calendar.current
		let dayOfMonth = calendar.component(.day, from: self)
		switch dayOfMonth {
		case 1, 21, 31: return "st"
		case 2, 22: return "nd"
		case 3, 23: return "rd"
		default: return "th"
		}
	}
	func adding(hours: Int) -> Date {
		return Calendar.current.date(byAdding: .hour, value: hours, to: self)!
	}
	func adding(minutes: Int) -> Date {
		return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
	}
}
