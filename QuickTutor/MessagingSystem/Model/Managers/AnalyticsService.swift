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
    
    func logCategoryClicked(_ categroryTitle: String) {
        Analytics.logEvent("category_tapped", parameters: nil)
    }
    
    func logSubcategoryTapped(_ subcategoryTitle: String) {
        let params = ["subcategory_name": subcategoryTitle]
        Analytics.logEvent("subcategory_tapped", parameters: params)
    }
    
    func logSubjectTapped(_ subject: String) {
        let params = ["subject": subject]
        Analytics.logEvent("subject_tapped", parameters: params)
    }
    
    func logSearch(_ searchTerm: String) {
        let params = ["search_term": searchTerm]
        Analytics.logEvent("search", parameters: params)
    }
    
    private init() {}
}

class SessionAnalyticsService {
    
    static let shared = SessionAnalyticsService()
    
    func getParamsFromSessionRequest(_ sessionRequest: SessionRequest) -> [String: Any] {
        let params: [String: Any] = ["subject": sessionRequest.subject, "session_type": sessionRequest.type, "price": sessionRequest.price]
        return params
    }
    
    func logSessionRequestSent(_ sessionRequest: SessionRequest) {
        let params = getParamsFromSessionRequest(sessionRequest)
        Analytics.logEvent("session_request_sent", parameters: params)
    }
    
    func logSessionRequestAccepted(_ sessionRequest: SessionRequest) {
        let params = getParamsFromSessionRequest(sessionRequest)
        Analytics.logEvent("session_request_accepted", parameters: params)

    }
    
    func logSessionRequestDeclined(_ sessionRequest: SessionRequest) {
        let params = getParamsFromSessionRequest(sessionRequest)
        Analytics.logEvent("session_request_declined", parameters: params)

    }
    
    private init() {}
}
