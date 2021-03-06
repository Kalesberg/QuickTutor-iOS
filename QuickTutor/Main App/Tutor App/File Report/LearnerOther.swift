//
//  LearnerOther.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class LearnerOtherView: FileReportSubmissionLayout {
    override func configureView() {
        super.configureView()
        header.text = "Other"

        textBody.font = Fonts.createSize(14)
        textBody.text = "QuickTutor's mission is to ensure all tutors have the best experience possible. Tell us what happened in your session and we'll do our best to make sure it doesn't happen again. Refer to the Tutor Handbook for more information."
    }

}

class LearnerOther: SubmissionViewControllerVC {
    override var contentView: LearnerOtherView {
        return view as! LearnerOtherView
    }

    var datasource: UserSession! {
        didSet {
            print("datasource Set.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }

    override func loadView() {
        view = LearnerOtherView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func handleNavigation() {
        if touchStartView is SubmitButton {
            if contentView.textView.textView.text!.count < 20 {
                contentView.errorLabel.isHidden = false
            } else {
                contentView.errorLabel.isHidden = true
                submitReport()
            }
        }
    }

    private func submitReport() {
        let value: [String: Any] = [
            "reportee": datasource.otherId,
            "reason": contentView.textView.textView.text,
            "type": FileReportTutor.Other.rawValue,
            "userType": "tutor",
            "name": CurrentUser.shared.learner.name.split(separator: " ")[0],
            "email": CurrentUser.shared.learner.email,
        ]

        FirebaseData.manager.fileReport(sessionId: datasource.id, reportStatus: datasource.reportStatus.reportStatusUpdate(type: "tutor"), value: value) { error in
            if error != nil {
                AlertController.genericErrorAlert(self, title: "Error Filing Report", message: "Something went wrong, please try again.")
            } else {
                self.customerServiceAlert {
                    self.navigationController?.popBackToMain()
                }
            }
        }
    }
}
