//
//  SessionRequestError.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

enum SessionRequestError: String {
    case none = ""
    case noTutor = "Select a tutor"
    case noSubject = "Select a subject"
    case noStartTime = "Select a time"
    case noDuration = "Select a duration"
    case noPrice = "Select a price"
    case noSessionType = "Select session type"
}
