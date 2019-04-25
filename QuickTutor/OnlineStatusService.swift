//
//  OnlineStatusService.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/16/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

class OnlineStatusService {
    
    static let shared = OnlineStatusService()
    
    var timer: Timer?
    var isActive = false
    
    private func handlePostingOnlineStatus() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (timer) in
            self.postOnlineStatus()
        })
        timer?.fire()
    }
    
    func makeActive() {
        timer?.invalidate()
        handlePostingOnlineStatus()
    }
    
    func resignActive() {
        timer?.invalidate()
        postOnlineStatus()
    }
    
    private func postOnlineStatus() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let timeStamp = Date().timeIntervalSince1970
        Database.database().reference().child("account").child(uid).child("online").setValue(timeStamp)
        
        // add status function
        UserStatusService.shared.updateUserStatus(uid, status: .online)
    }
    
    func getLastActiveStringFor(uid: String, completion: @escaping (String?, UserStatusType) -> Void) {
        UserStatusService.shared.getUserStatus(uid) { status in
            Database.database().reference().child("account").child(uid).child("online").observeSingleEvent(of: .value) { (snapshot) in
                guard let value = snapshot.value as? Double else {
                    completion("", .offline)
                    return
                }
                
                let differenceInSeconds = Date().timeIntervalSince1970 - value
                let status = status?.status ?? .offline
                let result = self.updateActiveStatus(seconds: differenceInSeconds, status: status)
                completion(result, status)
            }
        }
    }
    
    func updateActiveStatus(seconds: Double, status: UserStatusType) -> String {
        if status == .online {
            self.isActive = true
            return "Active now"
        }
        
        let time = TimeHelper()
        var result = ""
        self.isActive = false
        switch seconds {
        case 0..<time.oneMinuteInSeconds:
            result = "Just now"
        case time.oneMinuteInSeconds..<time.oneHourInSeconds:
            let duration = time.minutesFrom(seconds: seconds)
            result = self.activeWithDurationText(duration: duration, type: "min")
        case time.oneHourInSeconds..<time.oneDayInSeconds:
            let duration = time.hoursFrom(seconds: seconds)
            result = self.activeWithDurationText(duration: duration, type: "hour")
        case time.oneDayInSeconds..<time.mulitplyDaysInSeconds(by: 3):
            let duration = time.daysFrom(seconds: seconds)
            result = self.activeWithDurationText(duration: duration, type: "day")
        default:
            result = ""
        }
        return result
    }
    
    func activeWithDurationText(duration: Int, type: String) -> String {
        let length = duration == 1 ? type : type + "s"
        return "Active \(duration) \(length) ago"
    }
    
    private init() {}
    
}
