//
//  Learner.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class LearnerUnsafeView: FileReportSubmissionLayout {
    override func configureView() {
        super.configureView()
        header.text = "My learner made me feel unsafe"

        textBody.font = Fonts.createSize(14)
        textBody.text = "QuickTutor possess strict safety guidelines to keep your tutoring session as safe and comfortable as possible.\n\nRude, aggressive, or inappropriate physical contact or verbal aggression is not tolerated. If your learner did anything to make you feel uncomfortable or unsafe, please let us know here. "
    }

}

class LearnerUnsafe: SubmissionViewControllerVC {
    override var contentView: LearnerUnsafeView {
        return view as! LearnerUnsafeView
    }

    var datasource: UserSession! {
        didSet {
            print("datasource set")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }

    override func loadView() {
        view = LearnerUnsafeView()
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
            "type": FileReportTutor.LearnerUnsafe.rawValue,
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
