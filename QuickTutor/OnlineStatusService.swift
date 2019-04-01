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
    
    func getLastActiveStringFor(uid: String, completion: @escaping (String?) -> Void) {
        Database.database().reference().child("account").child(uid).child("online").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? Double else {
                completion("")
                return
            }
            let differenceInSeconds = Date().timeIntervalSince1970 - value
            print(differenceInSeconds)
            var result = ""
            if differenceInSeconds < 240 {
                result = "Active now"
                self.isActive = true
            } else if  differenceInSeconds >= 240 && differenceInSeconds < 3600 {
                result = "Active \(Int(differenceInSeconds / 60))m ago"
                self.isActive = false
            } else if differenceInSeconds >= 3600 && differenceInSeconds < 86400 {
                result = "Active \(Int(differenceInSeconds / 60 / 60))hr ago"
                self.isActive = false
            } else {
                result = ""
                self.isActive = false
            }
             completion(result)
        }
    }
    
    private init() {}
    
}
