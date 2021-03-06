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
    #if DEVELOPMENT
    static let DATABASE_URL = "https://quicktutor-dev.firebaseio.com/"
    static let STORAGE_URL = "gs://quicktutor-dev.appspot.com"
    static let API_BASE_URL = "https://us-central1-quicktutor-dev.cloudfunctions.net/api"
    static let STRIPE_PUBLISH_KEY = "pk_test_TtFmn5n1KhfNPgXXoGfg3O97"
    #else
    static let DATABASE_URL = "https://quicktutor-3c23b.firebaseio.com/"
    static let STORAGE_URL = "gs://quicktutor-3c23b.appspot.com"
    static let API_BASE_URL = "https://us-central1-quicktutor-3c23b.cloudfunctions.net/api"
    static let STRIPE_PUBLISH_KEY = "pk_live_D8MI9AN23eK4XLw1mCSUHi9V"
    #endif
    static let APPLE_PAY_MERCHANT_ID = "merchant.com.quicktutor"
    
    static var showSwipeTutorial : Bool = false
    static var showMainPageTutorial : Bool = false
    
    static let AVATAR_PLACEHOLDER_URL = URL(string: "https://firebasestorage.googleapis.com/v0/b/quicktutor-3c23b.appspot.com/o/avatar-placeholder.png?alt=media&token=bcc61052-0340-4d2d-a659-fbe54ecd70c1")
}

struct Colors {
    static let navBarGreen = UIColor(hex: "#50AA56")
    static let backgroundDark = UIColor(hex: "2C2C3B")
    static let divider = UIColor(hex:"121216")
    static let grayText = UIColor(hex:"999999")
    static let green = UIColor(hex:"1EAD4A")
    static let brightGreen = UIColor(hex:"31d662")
    static let purple = UIColor(hex:"6562C9")
    static let progressBlue = UIColor(hex:"4B5F8E")
    static let qtRed = UIColor(hex:"AF1C49")
    static let remainderProgressDark = UIColor(hex:"2A2A2F")
    static let sidebarPurple = UIColor(hex:"544177")
    static let yellow = UIColor(hex:"FADA4A")
    static let lightBlue = UIColor(hex: "6882BC")
    static let lightGrey = UIColor(hex: "0D0925").withAlphaComponent(0.2)
    static let accessoryBackground = UIColor(hex: "1a1a24")
    static let receivedMessage = UIColor(hex:"4C5E8D")
    static let sentMessage = UIColor(hex: "544177")
    static let border = UIColor(hex: "818186")
    static let gold = UIColor(hex: "FAAB1A")
    static let notificationRed = UIColor(hex: "FF0800")
    static let learnerReceipt = UIColor(hex: "807CFF")
    static let tutorReceipt = UIColor(hex: "C2D9FF")
    static let modalBackground = UIColor(hex: "1B1B25")
    
    //Request session
    static let selectedPurple = UIColor(hex: "#33325C")
    static let notSelectedPurple = UIColor(hex: "#4E4C9C")
    static let notSelectedTextColor = UIColor(hex: "#767692")
    
    //Redesign
    static let gray = UIColor(hex: "2C2C3A")
    static let registrationGray = UIColor.white.withAlphaComponent(0.5)
    static let darkGray = UIColor(hex: "1b1b26")
    static let buttonGray = UIColor(hex: "2f3c56")
    static let wheat = UIColor(hex: "feda75")
    static let orange = UIColor(hex: "fa7e1e")
    static let pink = UIColor(hex: "d62976")
    static let brightPurple = UIColor(hex: "962fbf")
    static let warmBlue = UIColor(hex: "4f5bd5")
    static let grayText80 = UIColor.white.withAlphaComponent(0.5)
    static let facebookColor = UIColor(hex: "0065E1")
    static let brightRed = UIColor(hex: "FF3C38")
    static let purpleBackground = UIColor(hex: "181827")
    
    static let newNavigationBarBackground = UIColor(hex: "15151E")
    static let newScreenBackground = UIColor(hex: "15151E")
    static let newTabbarBackgroundColor = UIColor(hex: "1B1B26").withAlphaComponent(0.9)
    static let newTextHighlightColor = UIColor(hex: "645FCC")
    
    static let statusActiveColor = UIColor(hex: "0FD513")
}

struct Fonts {
    static func createSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func createSemiBoldSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Semibold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    static func createBoldSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static func createBlackSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Black", size: size) ?? UIFont.systemFont(ofSize: size, weight: .black)
    }
    
    static func createItalicSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Italic", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func createBoldItalicSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-BoldItalic", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func createLightSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }
    
    static func createMediumSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
}
