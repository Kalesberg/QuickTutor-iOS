//
//  Learner.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class LearnerProfilePicsView: FileReportSubmissionLayout {
    override func configureView() {
        super.configureView()
        header.text = "My learner didn't match their profile picture(s)"

        textBody.font = Fonts.createSize(14)
        textBody.text = "Upon registration, every learner and QuickTutor is required to upload a profile picture, which helps both users recognize each other when meeting for in-person tutoring sessions.\n\nIf you believe that your learner for this session was not who you were expecting, please notify us here."
    }

}

class LearnerProfilePics: SubmissionViewControllerVC {
    override var contentView: LearnerProfilePicsView {
        return view as! LearnerProfilePicsView
    }

    var datasource: UserSession! {
        didSet {
            print("datasource set.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        navigationItem.title = "File Report"
    }

    override func loadView() {
        view = LearnerProfilePicsView()
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
            "type": FileReportTutor.DidNotMatch.rawValue,
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
