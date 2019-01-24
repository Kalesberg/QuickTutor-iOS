//
//  TutorLate.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorLateView: FileReportCheckboxLayout {
    override func configureView() {
        super.configureView()
        header.text = "My tutor was late"

        textBody.font = Fonts.createSize(14)
        textBody.text = "Tutors have the option to create their own custom cancellation policy (CCP) — which learners are subject to upon scheduling a session with a tutor. This includes late fees. However, tutors are subject to their own policies as well.\n\nIf your tutor disobeyed their late policy, please let us know. Note that a report must be filed no earlier than 30 mins before the scheduled end of a session. And cannot be filed more than 7 days after the date of the scheduled session.\n"

        cb1.label.text = "Tutor arrived late"
        cb2.label.text = "Tutor arrived extensively late"
        cb3.label.text = "Tutor didn't show up to the session"
    }

}

class TutorLateVC: BaseViewController {
    override var contentView: TutorLateView {
        return view as! TutorLateView
    }

    var type = 0

    var datasource: UserSession! {
        didSet {
            print("datasource set.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "File Report"
    }

    override func viewDidLayoutSubviews() {}

    override func loadView() {
        view = TutorLateView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func handleNavigation() {
        if touchStartView == contentView.cb1.checkbox {
            type = 1
            contentView.cb2.checkbox.isSelected = false
            contentView.cb3.checkbox.isSelected = false
        } else if touchStartView == contentView.cb2.checkbox {
            type = 2
            contentView.cb1.checkbox.isSelected = false
            contentView.cb3.checkbox.isSelected = false
        } else if touchStartView == contentView.cb3.checkbox {
            type = 3
            contentView.cb1.checkbox.isSelected = false
            contentView.cb2.checkbox.isSelected = false
        } else if touchStartView is SubmitButton {
            submitReport()
        }
    }

    private func submitReport() {
        guard let reason = getReason() else {
            AlertController.genericErrorAlert(self, title: "Select an Option!!", message: "In order to better process your report, we suggest that you select an option.")
            return
        }

        let value: [String: Any] = [
            "reportee": datasource.otherId,
            "reason": reason,
            "type": FileReportLearner.TutorLate.rawValue,
            "userType": "learner",
            "name": CurrentUser.shared.learner.name.split(separator: " ")[0],
            "email": CurrentUser.shared.learner.email,
        ]

        FirebaseData.manager.fileReport(sessionId: datasource.id, reportStatus: datasource.reportStatus.reportStatusUpdate(type: "learner"), value: value) { error in
            if error != nil {
                AlertController.genericErrorAlert(self, title: "Error Filing Report", message: "Something went wrong, please try again.")
            } else {
                self.customerServiceAlert {
                    self.navigationController?.popBackToMain()
                }
            }
        }
    }

    private func getReason() -> String? {
        switch type {
        case 1:
            if contentView.cb1.checkbox.isSelected {
                return "Tutor arrived late"
            }
            return nil
        case 2:
            if contentView.cb2.checkbox.isSelected {
                return "Tutor arrived extensively late"
            }
            return nil
        case 3:
            if contentView.cb3.checkbox.isSelected {
                return "Tutor didn't show up to the session"
            }
            return nil
        default:
            return nil
        }
    }
}
