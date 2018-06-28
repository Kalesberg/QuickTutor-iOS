//
//  TutorMainPageFactory.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/23/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

enum TutorMainPageButtonFactory {
	
	case tutorRating, tutorTrending, tutorEarning
	
	static let buttons : [TutorMainPageButtonFactory] = [.tutorRating, .tutorTrending, .tutorEarning]
	
	var mainPageButton : MainPageButton {
		switch self {
		case .tutorRating:
			return MainPageButton(icon: #imageLiteral(resourceName: "ratings"), label: "Your Ratings", color: Colors.gold)
		case .tutorTrending:
			return MainPageButton(icon: #imageLiteral(resourceName: "trending"), label: "View Trending", color: UIColor(hex: "5785D4"))
		case .tutorEarning:
			return MainPageButton(icon: #imageLiteral(resourceName: "earnings"), label: "Your Earnings", color: Colors.green)
		}
	}
	var viewController : UIViewController {
		switch self {
		case .tutorRating: return TutorRatings()
		case .tutorEarning: return TutorEarnings()
		case .tutorTrending: return TrendingCategories()
		}
	}
}

struct MainPageButton {
	let icon : UIImage
	let label : String
	let color : UIColor
	
	init(icon: UIImage, label: String, color: UIColor) {
		self.icon = icon
		self.label = label
		self.color = color
	}
}

enum TutorMainPageCellFactory {
	case featured, improve, shareUsername

	static let cells : [TutorMainPageCellFactory] = [.featured, .improve, .shareUsername]
	
	var mainPageCell : MainPageCell {
		switch self {
		case .featured:
			return MainPageCell(title: "Want to get featured?", subtitle: "Learn more about hitting the front page.")
		case .improve:
			return MainPageCell(title: "Looking to improve?", subtitle: "See tips on how to become a better tutor!")
		case .shareUsername:
			return MainPageCell(title: "Share your username", subtitle: "Post your username to other platforms!")
		}
	}
	var viewController : UIViewController {
		switch self {
		case .improve: return TutorMainTips()
		case .featured: return TutorListings()
		case .shareUsername:
			let text = "Go checkout QuickTutor!"
			let webUrl = URL(string:"https://QuickTutor.com")
			let shareAll : [Any] = [text, webUrl ?? ""]
			let activityController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
			activityController.isModalInPopover = true
			return activityController
		}
	}
}

struct MainPageCell {
	let title : String
	let subtitle : String
}
