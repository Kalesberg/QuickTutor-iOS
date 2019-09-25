//
//  QTConstants.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 7/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTConstants {
    static let APP_STORE_URL = "https://apps.apple.com/us/app/quicktutor/id1388092698"
    static let RATE_APP_MESSAGE_LIMIT = 5
    
    static let learnerMaxInterests = 12
}

struct QTUserDefaultsKey {
    static let leanerRecentSearches = "leanerRecentSearches"
    
    static let tutorFirstMessages = "tutorFirstMessages"
    static let tutorAppRateForFiveMessages = "tutorAppRateForFiveMessages"
    static let tutorAppRateForFirstSession = "tutorAppRateForFirstSession"
    static let learnerFirstMessages = "learnerFirstMessages"
    static let learnerAppRateForFiveMessages = "learnerAppRateForFiveMessages"
    static let learnerAppRateForFirstSession = "learnerAppRateForFirstSession"
}

struct QTNotificationName {
    static let quickSearchAll = "quickSearchAll"
    static let quickSearchSubjects = "quickSearchSubjects"
    static let quickSearchPeople = "quickSearchPeople"
    static let quickSearchBegin = "quickSearchBegin"
    static let quickSearchEnd = "quickSearchEnd"
    static let quickSearchClearSearchKey = "quickSearchClearSearchKey"
    static let quickSearchDismissKeyboard = "quickSearchDismissKeyboard"
}

let AVATAR_PLACEHOLDER_IMAGE = UIImage(named: "ic_avatar_placeholder")
