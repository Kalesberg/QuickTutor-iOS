//
//  UserStatus.swift
//  QuickTutor
//

import Foundation
import Firebase

enum UserStatusType: Int {
    case offline, away, online
}

class UserStatus {
    var userId: String?
    var status: UserStatusType?
    
    init(_ userId: String, status: UserStatusType) {
        self.userId = userId
        self.status = status
    }
    
    init(_ userId: String, status: Int) {
        self.userId = userId
        self.status = UserStatusType(rawValue: status)
    }
}
