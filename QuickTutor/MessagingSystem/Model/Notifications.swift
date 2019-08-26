//
//  Notifications.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import Foundation

struct Notifications {
    static let test = Notification(name: Notification.Name(rawValue: "com.quicktutor.close"))
    static let didEnterBackground = Notification(name: Notification.Name(rawValue: "com.quickTutor.didEnterBackground"))
    static let didEnterForeground = Notification(name: Notification.Name(rawValue: "com.quickTutor.didEnterForeground"))
    static let willTerminate = Notification(name: Notification.Name(rawValue: "com.quickTutor.willTerminate"))
    static let didDisconnect = Notification(name: Notification.Name(rawValue: "com.quickTutor.didDisconnect"))
    static let tutorSubjectsDidChange = Notification(name: Notification.Name("com.quickTutor.tutorSubjectsChanged"))
    static let tutorDidAddSubject = Notification(name: Notification.Name("com.quickTutor.tutorDidAddSubject"))
    static let tutorDidRemoveSubject = Notification(name: Notification.Name("com.quickTutor.tutorDidRemoveSubject"))
    static let showSessionCardManager = Notification(name: Notification.Name("com.quickTutor.session.showCardManagerVC"))
    
    static let learnerDidAddInterest = Notification(name: Notification.Name("com.quickTutor.learnerDidAddInterest"))
    static let learnerDidRemoveInterest = Notification(name: Notification.Name("com.quickTutor.learnerDidRemoveInterest"))
    static let learnerTooManyInterests = Notification(name: Notification.Name("com.quickTutor.learnerTooManyInterests"))
    
    static let learnerDidSelectQuickRequestSubject = Notification(name: Notification.Name("com.quickTutor.learnerDidSelectQuickRequestSubject"))
}

struct NotificationNames {
    struct LearnerMainFeed {
        static let featuredSectionTapped = Notification.Name("com.quickTutor.featuredTapped")
        static let categoryTapped = Notification.Name("com.quickTutor.CategoryTapped")
        static let topTutorTapped = Notification.Name("com.quickTutor.topTutorTapped")
        static let seeAllTopTutorsTapped = Notification.Name("com.quickTutor.seeAllTopTutorsTapped")
        static let suggestedTutorTapped = Notification.Name("com.quickTutor.suggestedTutorTapped")
        static let activeTutorCellTapped = Notification.Name("com.quickTutor.activeTutorCellTapped")
        static let activeTutorMessageButtonTapped = Notification.Name("com.quickTutor.activeTutorMessageButtonTapped")
        static let searchesLoaded = Notification.Name("com.quickTutor.searchesLoaded")
        static let recentSearchCellTapped = Notification.Name("com.quickTutor.recentSearchCellTapped")
        static let quickRequestCellTapped = Notification.Name("com.quickTutor.quickRequestCellTapped")
        static let reloadSessions = Notification.Name("com.quickTutor.reloadSessions")
        static let requestSession = Notification.Name("com.quickTutor.requestSession")
    }
    struct QuickSearch {
        static let updatedFilters = Notification.Name("com.quickTutor.updatedFilters")
    }
    
    struct SavedTutors {
        static let didUpdate = Notification.Name("com.qt.savedTutorsDidUpdate")
    }
    
    struct Documents {
        static let didStartUpload = Notification.Name(rawValue: "com.qt.documentUploadStarted")
        static let didFinishUpload = Notification.Name(rawValue: "com.qt.documentUploadFinished")
    }
}

struct PushNotification {
    var identifier: String
    var category: NotificationCategory
    var senderId: String?
    var receiverId: String?
    var senderAccountType: String?
    var receiverAccountType: String?
    var sessionId: String?

    func partnerId() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        guard let senderIdIn = senderId, let receiverIdIn = receiverId else { return nil }
        return senderId == uid ? receiverIdIn : senderIdIn
    }

    init(userInfo: [AnyHashable: Any]) {
        identifier = userInfo["identifier"] as? String ?? ""
        category = NotificationCategory(rawValue: userInfo["category"] as? String ?? "sessionStart")!
        senderId = userInfo["senderId"] as? String
        receiverId = userInfo["receiverId"] as? String
        senderAccountType = userInfo["senderAccountType"] as? String
        receiverAccountType = userInfo["receiverAccountType"] as? String
        sessionId = userInfo["sessionId"] as? String
    }
}
