//
//  DynamicLinkFactory.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/25/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import FirebaseDynamicLinks
import UIKit
import FirebaseDatabase

class DynamicLinkFactory {
    static let shared = DynamicLinkFactory()

#if DEVELOPMENT
    let domain = "https://quicktutordev.page.link"
#else
    let domain = "https://quicktutor.page.link"
#endif
    
    var sections = [Section]()
    var dictionary = [Params: String]()
    var longLink: URL?
    var shortLink: URL?

    func createLink(userId: String, username: String, subject: String, profilePreviewUrl: String?, completion: @escaping (URL?) -> Void) {
        dictionary[.link] = "https://quickTutor.com/\(userId)"
        // Initialize the sections array
        sections = [
            Section(name: .iOS, items: [.bundleID, .fallbackURL, .minimumAppVersion, .customScheme,
                                        .iPadBundleID, .iPadFallbackURL, .appStoreID]),
            Section(name: .iTunes, items: [.affiliateToken, .campaignToken, .providerToken]),
        ]

        dictionary[.bundleID] = Bundle.main.bundleIdentifier!
        let iOSParams = DynamicLinkIOSParameters(bundleID: dictionary[.bundleID]!)
        iOSParams.appStoreID = "1388092698"
        guard let linkString = dictionary[.link] else {
            print("Link can not be empty!")
            completion(nil)
            return
        }
        guard let link = URL(string: linkString) else {
            completion(nil)
            return
        }
        
        let currentUserType = AccountService.shared.currentUserType
        
        guard let currentUser = AccountService.shared.currentUser,
            let currentUserId = currentUser.uid else {
                completion(nil)
                return
        }
        
        let components = DynamicLinkComponents(link: link, domainURIPrefix: domain)
        let socialParams = DynamicLinkSocialMetaTagParameters()
        
        if currentUserType == UserType.tutor && userId.compare(currentUserId) == .orderedSame {
            socialParams.title = "I teach \(subject) on QuickTutor. Connect with me, my username is \(username)!"
        } else {
            socialParams.title = "\(username) teaches \(subject) on QuickTutor. Connect with them to learn."
        }
        socialParams.descriptionText = "Check out this QuickTutor!"

#if DEVELOPMENT
        if let profilePreviewUrl = profilePreviewUrl {
            socialParams.imageURL = URL(string: profilePreviewUrl)
        } else {
            socialParams.imageURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/quicktutor-dev.appspot.com/o/logoWithTrademark.png?alt=media&token=2baf6fa7-fd6f-4bf6-a89c-a47429561278")
        }
#else
        if let profilePreviewUrl = profilePreviewUrl {
            socialParams.imageURL = URL(string: profilePreviewUrl)
        } else {
            socialParams.imageURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/quicktutor-3c23b.appspot.com/o/newLogoWithTrademark.png?alt=media&token=6c9610fb-09fa-4f99-8cbf-1b48a6414407")
        }
#endif

        components?.socialMetaTagParameters = socialParams

        components?.iOSParameters = iOSParams
        longLink = components?.url

        components?.shorten { url, _, _ in
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
    case iOS
    case iTunes = "iTunes Connect Analytics"
    case android = "Android"
    case social = "Social Meta Tag"
    case other = "Other Platform"
}
