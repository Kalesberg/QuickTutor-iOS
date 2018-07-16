//
//  RequestSessionCellFactory.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import CoreLocation

protocol RequestSessionDelegate {
	func sessionSubjectChanged(subject: String)
	func priceDidChange(price: Int)
	func startTimeDateChanged(date: Date)
	func durationChanged(displayDuration: String?, duration: Int?)
	func isOnlineChanged(isOnline: Bool?)
}

struct TutorPreferenceData {
	let name : String
	let subjects : [String]
	let sessionPreference : Int
	let travelPreference : Int
	let pricePreference : Int
	
	init(dictionary: [String : Any]) {
		self.subjects = dictionary["subjects"] as? [String] ?? []
		self.sessionPreference = dictionary["session"] as? Int ?? 3
		self.travelPreference = dictionary["distance"] as? Int ?? 0
		self.pricePreference = dictionary["price"] as? Int ?? 0
		self.name = dictionary["name"] as? String ?? ""
	}
}

struct RequestSessionData {
	
	static var subject : String? = nil
	static var startTime : Date? = nil
	static var duration : Int? = nil
	static var displayDuration : String? = nil
	static var price : Int? = nil
	static var isOnline : Bool? = nil
	
	static func clearSessionData() {
		subject = nil
		startTime = nil
		duration = nil
		price = nil
		displayDuration = nil
		duration = nil
		isOnline = nil
	}
}


public enum RequestSessionCellFactory {
	case subject, startTime, endTime, price, type
	
	static let requestSessionCells : [RequestSessionCellFactory] = [.subject, .startTime, .endTime, .price, .type]
	
	struct RequestSessionCellData {
		let title : String
		var subtitle : NSMutableAttributedString?
		init(title: String, subtitle: NSMutableAttributedString?) {
			self.title = title
			self.subtitle = subtitle
		}
	}
	
	var cellData : RequestSessionCellData {
		switch self {
		case .subject:
			let formattedString = (RequestSessionData.subject == nil) ? NSMutableAttributedString().regular("Choose a subject", 14, .white) : NSMutableAttributedString().bold(RequestSessionData.subject!, 15, .white)
			return RequestSessionCellData(title: "Subject", subtitle: formattedString)
		case .startTime:
			let formattedString = (RequestSessionData.startTime == nil) ? NSMutableAttributedString().regular("Choose a start time for this session", 14, .white) : NSMutableAttributedString().bold(sessionDateToString(), 15, .white)
			return RequestSessionCellData(title: "Start Time", subtitle: formattedString)
		case .endTime:
			let formattedString = (RequestSessionData.displayDuration == nil) ? NSMutableAttributedString().regular("Choose a duration for this session", 14, .white) : NSMutableAttributedString().bold(RequestSessionData.displayDuration!, 15, .white)
			return RequestSessionCellData(title: "Session Duration", subtitle: formattedString)
		case .price:
			let formattedString = (RequestSessionData.price == nil) ? NSMutableAttributedString().regular("Choose a price for this session", 14, .white) : NSMutableAttributedString().bold("$\(RequestSessionData.price!)", 15, .white).regular("   /hr", 11, .white)
			return RequestSessionCellData(title: "Price", subtitle: formattedString)
		case .type:
			let formattedString = (RequestSessionData.isOnline == nil) ? NSMutableAttributedString().regular("Choose a session type", 14, .white) : NSMutableAttributedString().bold(RequestSessionData.isOnline! ? "Online (Video)" : "In-Person", 15, .white)
			return RequestSessionCellData(title: "Session Type", subtitle: formattedString)
		}
	}
	
	private func sessionDateToString() -> String {
		if let date = RequestSessionData.startTime {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "EEEE MMMM d'\(date.daySuffix())', h:mm a"
			return dateFormatter.string(from: date)
		}
		return "Choose a start time for this session."
	}
}
