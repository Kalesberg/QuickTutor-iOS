//
//  QTQuickRequestService.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class QTQuickRequestService {
    static let shared = QTQuickRequestService()
    
    var subject: String?
    var sessionType: QTSessionType = .online
    var startTime: Date = Date().adding(minutes: 15)
    var duration: Int = 20
    var minPrice: Double?
    var maxPrice: Double?
    
    func reset() {
        subject = nil
        sessionType = .online
        startTime = Date().adding(minutes: 15)
        duration = 20
        minPrice = nil
        maxPrice = nil
    }
    
    func sendQuickRequest(_ completion: ((Bool?, String?) -> Void)?) {
        
        guard let uid = CurrentUser.shared.learner.uid else {
            if let completion = completion {
                completion(false, "You can't submit the request.")
            }
            return
        }
        var requestData = [String: Any] ()
        requestData["subject"] = subject
        requestData["date"] = startTime.timeIntervalSince1970
        requestData["startTime"] = startTime.timeIntervalSince1970
        let endTime = startTime.adding(minutes: duration).timeIntervalSince1970
        requestData["endTime"] = endTime
        requestData["type"] = sessionType.rawValue
        requestData["minPrice"] = minPrice
        requestData["maxPrice"] = maxPrice
        requestData["expired"] = false
        requestData["senderId"] = uid
        requestData["duration"] = duration * 60
        let expiration = (endTime - Date().timeIntervalSince1970) / 2
        let expirationDate = Date().addingTimeInterval(expiration).timeIntervalSince1970
        requestData["expiration"] = expirationDate
        
        Database.database().reference().child("quickRequests").childByAutoId().setValue(requestData) { (error, ref) in
            if let error = error {
                if let completion = completion {
                    completion(false, error.localizedDescription)
                    return
                }
            }
            
            if let uid = ref.key {
                ref.updateChildValues(["uid": uid])
                if let completion = completion {
                    completion(true, nil)
                    return
                }
            }
            
            if let completion = completion {
                completion(false, "Faild to submit the request.")
            }
        }
        
    }
}
