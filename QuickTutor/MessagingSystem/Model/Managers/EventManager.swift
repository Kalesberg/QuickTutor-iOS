//
//  EventManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import EventKit
import UIKit

class EventManager {
    var parentController: UIViewController

    func addSessionToCalender(_ session: SessionRequest, forCell cell: SessionRequestCell) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if error != nil { return }
            if granted {
                let event: EKEvent = EKEvent(eventStore: eventStore)
                event.title = "QuickTutor session: \(session.subject!)"
                event.startDate = NSDate(timeIntervalSince1970: session.startTime!) as Date
                event.endDate = NSDate(timeIntervalSince1970: session.endTime!) as Date
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    DispatchQueue.main.async {
                        AlertController.genericErrorAlertWithoutCancel(self.parentController, title: "Oops!", message: error.localizedDescription)
                    }
                }
                DispatchQueue.main.async {
                    cell.setStatusLabel()
                }
            } else {
                DispatchQueue.main.async {
                    AlertController.requestPermissionFromSettingsAlert(self.parentController, title: nil, message: "This action requires access to Calendar. Would you like to open settings and grant permission to Calendar?")
                }
            }
        }
    }

    init(parentController: UIViewController) {
        self.parentController = parentController
    }
}
