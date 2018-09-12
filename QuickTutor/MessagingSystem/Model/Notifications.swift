//
//  Notifications.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

struct Notifications {
    static let test = Notification(name: Notification.Name(rawValue: "com.quicktutor.close"))
    static let didEnterBackground = Notification(name: Notification.Name(rawValue: "com.quickTutor.didEnterBackground"))
    static let didEnterForeground = Notification(name: Notification.Name(rawValue: "com.quickTutor.didEnterForeground"))
    static let willTerminate = Notification(name: Notification.Name(rawValue: "com.quickTutor.willTerminate"))
    static let showOverlay =  Notification(name: Notification.Name(rawValue: "com.quickTutor.showOverlay"))
    static let hideOverlay =  Notification(name: Notification.Name(rawValue: "com.quickTutor.hideOverlay"))
}
