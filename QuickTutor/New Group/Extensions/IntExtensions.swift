//
//  IntExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit

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
	func formatPrice() -> String {
		return "$\(self) / hour"
	}
	func formatReviewLabel(rating: Double) -> String {
		if self == 1 {
			return "\(self) Review ★ \(rating)"
		}
		return "\(self) Reviews ★ \(rating)"
	}
	func formatDistance() -> NSMutableAttributedString {
		
		let formattedString = NSMutableAttributedString()
		
		formattedString
			.bold("\(self)", 17, Colors.lightBlue)
			.regular("\n", 0, .clear)
			.bold("miles", 12, Colors.lightBlue)
		
		
		let paragraphStyle = NSMutableParagraphStyle()
		
		paragraphStyle.alignment = .center
		paragraphStyle.lineSpacing = -2
		
		formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
		
		return formattedString
	}
}
extension Double {
	func formatDistance() -> NSMutableAttributedString {
		
		let formattedString = NSMutableAttributedString()
		
		if self >= 500 {
			formattedString
				.bold("500+", 17, Colors.lightBlue)
				.regular("\n", 0, .clear)
				.bold("miles", 12, Colors.lightBlue)
		}else {
			formattedString
				.bold("\(self)", 17, Colors.lightBlue)
				.regular("\n", 0, .clear)
				.bold("miles", 12, Colors.lightBlue)
		}
		
		let paragraphStyle = NSMutableParagraphStyle()
		
		paragraphStyle.alignment = .center
		paragraphStyle.lineSpacing = -2
		
		formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
		
		return formattedString
	}
}
