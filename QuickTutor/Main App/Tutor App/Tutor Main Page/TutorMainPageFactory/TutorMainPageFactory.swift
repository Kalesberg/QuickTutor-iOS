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
    case tutorRating, tutorTrending, tutorEarning, tutorListing

    static let buttons: [TutorMainPageButtonFactory] = [.tutorRating, .tutorTrending, .tutorEarning, .tutorListing]

    var mainPageButton: MainPageButton {
        switch self {
        case .tutorRating:
            return MainPageButton(icon: #imageLiteral(resourceName: "tutor-ratings"), label: "Ratings")
        case .tutorTrending:
            return MainPageButton(icon: #imageLiteral(resourceName: "tutor-trending"), label: "Trending")
        case .tutorEarning:
            return MainPageButton(icon: #imageLiteral(resourceName: "tutor-earnings"), label: "Earnings")
        case .tutorListing:
            return MainPageButton(icon: #imageLiteral(resourceName: "tutor-listings"), label: "Listings")
        }
    }

    var viewController: UIViewController {
        switch self {
        case .tutorRating: return TutorRatingsVC()
        case .tutorEarning: return TutorEarnings()
        case .tutorTrending: return TrendingCategories()
        case .tutorListing: return YourListingVC()
        }
    }
}

struct MainPageButton {
    let icon: UIImage
    let label: String

    init(icon: UIImage, label: String) {
        self.icon = icon
        self.label = label
    }
}

enum TutorMainPageCellFactory {
    case featured, improve, shareUsername

    static let cells: [TutorMainPageCellFactory] = [.featured, .improve, .shareUsername]

    var mainPageCell: MainPageCell {
        switch self {
        case .featured:
            return MainPageCell(title: "Want to get featured?", subtitle: "Learn more about hitting the front page.")
        case .improve:
            return MainPageCell(title: "Looking to improve?", subtitle: "See tips on how to become a better tutor!")
        case .shareUsername:
            return MainPageCell(title: "Share your username", subtitle: "Post your username to other platforms!")
        }
    }

    var viewController: UIViewController {
        switch self {
        case .improve: return TutorMainTips()
        case .featured: return TutorListings()
        case .shareUsername:
            let text = "Go checkout QuickTutor!"			
            let webUrl = URL(string: "https://QuickTutor.com")
            let shareAll: [Any] = [text, webUrl ?? ""]
            let activityController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityController.isModalInPopover = true
            return activityController
        }
    }
}

struct MainPageCell {
    let title: String
    let subtitle: String
}
