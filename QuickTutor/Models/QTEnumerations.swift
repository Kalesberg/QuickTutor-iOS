//
//  QTEnumerations.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 7/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTEnumerations {

}

enum QTRecentSearchType: Int {
    case subject = 1
    case people = 2
}

enum QTSessionStatusType: String {
    case accepted = "accepted"
    case declined = "declined"
    case cancelled = "cancelled"
    case pending = "pending"
    case completed = "completed"
}

enum QTNewsType: String {
    case news = "news"
    case tip = "tip"
}
