//
//  DynamicLinkFactory.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/25/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks

class DynamicLinkFactory {
    
    static let shared = DynamicLinkFactory()
    
    let domain = "ev7bd.app.goo.gl"
    var sections = [Section]()
    var dictionary = [Params: String]()
    var longLink: URL?
    var shortLink: URL?
    
    
    func createLinkForUserId(_ userId: String, completion: @escaping(URL?) -> ()) {
        dictionary[.link] = "https://quickTutor.com/\(userId)"
        // Initialize the sections array
        sections = [
            Section(name: .iOS, items: [.bundleID, .fallbackURL, .minimumAppVersion, .customScheme,
                                        .iPadBundleID, .iPadFallbackURL, .appStoreID]),
            Section(name: .iTunes, items: [.affiliateToken, .campaignToken, .providerToken]),
        ]
        
        dictionary[.bundleID] = Bundle.main.bundleIdentifier!
        let iOSParams = DynamicLinkIOSParameters(bundleID: dictionary[.bundleID]!)
        iOSParams.appStoreID = "1352885966"
        guard let linkString = dictionary[.link] else {
            print("Link can not be empty!")
            completion(nil)
            return
        }
        guard let link = URL(string: linkString) else {
            completion(nil)
            return
        }
        let components = DynamicLinkComponents(link: link, domain: domain)
        
        let socialParams = DynamicLinkSocialMetaTagParameters()
        socialParams.title = "Quick Tutor: Here's an awesome tutor for you."
        socialParams.descriptionText = "Check out this user"
        socialParams.imageURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/quicktutormessaging.appspot.com/o/ItunesArtwork%402x.png?alt=media&token=c7606b8b-f0db-469f-852e-4ef01795758e")
        components.socialMetaTagParameters = socialParams
        
        components.iOSParameters = iOSParams
        longLink = components.url
        
        components.shorten { (url, warnings, erorr) in
            guard let url = url else { return }
            completion(url)
        }
        
    }
}

struct Section {
    var name: ParamTypes
    var items: [Params]
    var collapsed: Bool
    
    init(name: ParamTypes, items: [Params], collapsed: Bool = true) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}

enum Params: String {
    case link = "Link Value"
    case source = "Source"
    case medium = "Medium"
    case campaign = "Campaign"
    case term = "Term"
    case content = "Content"
    case bundleID = "App Bundle ID"
    case fallbackURL = "Fallback URL"
    case minimumAppVersion = "Minimum App Version"
    case customScheme = "Custom Scheme"
    case iPadBundleID = "iPad Bundle ID"
    case iPadFallbackURL = "iPad Fallback URL"
    case appStoreID = "AppStore ID"
    case affiliateToken = "Affiliate Token"
    case campaignToken = "Campaign Token"
    case providerToken = "Provider Token"
    case packageName = "Package Name"
    case androidFallbackURL = "Android Fallback URL"
    case minimumVersion = "Minimum Version"
    case title = "Title"
    case descriptionText = "Description Text"
    case imageURL = "Image URL"
    case otherFallbackURL = "Other Platform Fallback URL"
}

enum ParamTypes: String {
    case googleAnalytics = "Google Analytics"
    case iOS = "iOS"
    case iTunes = "iTunes Connect Analytics"
    case android = "Android"
    case social = "Social Meta Tag"
    case other = "Other Platform"
}
