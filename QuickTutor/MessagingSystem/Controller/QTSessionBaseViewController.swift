//
//  QTSessionBaseViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 5/29/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class QTSessionBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func updateSessionStartTime(sessionId: String, duration: Double) {
        // Updated the startTime of a session because the session is able to start early than expected.
        let startTime = Date().timeIntervalSince1970
        Database.database().reference()
            .child("sessions")
            .child(sessionId)
            .updateChildValues(["startTime": startTime, "endTime": startTime + duration])
    }
    
    func updateSessionEndTime(sessionId: String) {
        // Updated the endTime of a session because the session is able to start early than expected.
        Database.database().reference()
            .child("sessions")
            .child(sessionId)
            .updateChildValues(["endTime": Date().timeIntervalSince1970])
    }

}
