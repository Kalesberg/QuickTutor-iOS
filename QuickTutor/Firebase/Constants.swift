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
}

struct Colors {
    static let backgroundDark = UIColor(hex: "272630")
    static let divider = UIColor(hex:"121216")
    static let grayText = UIColor(hex:"999999")
    static let green = UIColor(hex:"1EAD4A")
    static let learnerPurple = UIColor(hex:"4E376F")
    static let progressBlue = UIColor(hex:"4B5F8E")
    static let qtRed = UIColor(hex:"AF1C49")
    static let registrationDark = UIColor(hex:"1E1E26")
    static let remainderProgressDark = UIColor(hex:"2A2A2F")
    static let sidebarPurple = UIColor(hex:"544177")
    static let tutorBlue = UIColor(hex:"3E5486")
    static let yellow = UIColor(hex:"FADA4A")
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
