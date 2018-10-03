//
//  AnalyticsService.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Firebase

class AnalyticsService {
    
    static let shared = AnalyticsService()
    
    
    func logSessionStart(_ session: Session) {
        var params = [String: Any]()
        params["type"] = session.type
        params["subject"] = session.subject
        params["hourlyRate"] = session.price
        Analytics.logEvent("session_started", parameters: params)
    }
    
    func logSessionPayment(cost: Double, tip: Double) {
        let params = ["cost": cost, "tip": tip]
        Analytics.logEvent("session_payment", parameters: params)
    }
    
    private init() {}
}
