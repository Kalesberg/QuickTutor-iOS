//
//  Constants.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

public struct Constants {
    static let BCK_SPACE = -92
    static let VRFCTN_ID = "firebase_verification_id"
    static let DATABASE_URL = "https://quicktutor-3c23b.firebaseio.com/"
    static let STORAGE_URL = "gs://quicktutor-3c23b.appspot.com"
    
    static var showSwipeTutorial : Bool = false
    static var showMainPageTutorial : Bool = false
}

struct Colors {
    static let navBarGreen = UIColor(hex: "#50AA56")
    static let backgroundDark = UIColor(hex: "272630")
    static let divider = UIColor(hex:"121216")
    static let grayText = UIColor(hex:"999999")
    static let green = UIColor(hex:"1EAD4A")
    static let brightGreen = UIColor(hex:"31d662")
    static let learnerPurple = UIColor(hex:"4E376F")
    static let progressBlue = UIColor(hex:"4B5F8E")
    static let qtRed = UIColor(hex:"AF1C49")
    static let registrationDark = UIColor(hex:"1B1B26")
    static let remainderProgressDark = UIColor(hex:"2A2A2F")
    static let sidebarPurple = UIColor(hex:"544177")
    static let tutorBlue = UIColor(hex:"3E5486")
    static let yellow = UIColor(hex:"FADA4A")
    static let lightBlue = UIColor(hex: "6882BC")
    static let lightGrey = UIColor(hex: "0D0925").withAlphaComponent(0.2)
    static let purple = UIColor(hex: "544177")
    static let darkBackground = UIColor(hex: "272731")
    static let receivedMessage = UIColor(hex:"4C5E8D")
    static let sentMessage = UIColor(hex: "544177")
    static let border = UIColor(hex: "818186")
    static let navBarColor = UIColor(hex: "1B1B26")
    static func currentUserColor() -> UIColor {
        return AccountService.shared.currentUserType == .tutor ? tutorBlue : learnerPurple
    }
    static func otherUserColor() -> UIColor {
        return AccountService.shared.currentUserType == .tutor ? learnerPurple : tutorBlue
    }
}

struct Fonts {
    static func createSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func createBoldSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func createItalicSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Italic", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func createBoldItalicSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-BoldItalic", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func createLightSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
