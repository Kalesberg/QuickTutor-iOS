//
//  LearnerRude.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class LearnerRudeView: FileReportSubmissionLayout {
    override func configureView() {
        super.configureView()
        header.text = "My learner was rude"

        textBody.font = Fonts.createSize(14)
        textBody.text = "QuickTutor has a zero tolerance policy for learners who are rude/unprofessional to their tutors. As a tutor, your feedback on sessions, including ratings and reviews helps us improve session quality for others.\n\nAll users agree to a high standard of service that includes being polite, professional, and respectful. If you believe your learner has been unprofessional, please share your experience."
    }

}

class LearnerRude: SubmissionViewControllerVC {
    override var contentView: LearnerRudeView {
        return view as! LearnerRudeView
    }

    var automaticScroll = false

    var datasource: UserSession! {
        didSet {
            print("set.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        contentView.layoutIfNeeded()
    }

    override func loadView() {
        view = LearnerRudeView()
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
            "type": FileReportTutor.LearnerRude.rawValue,
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
