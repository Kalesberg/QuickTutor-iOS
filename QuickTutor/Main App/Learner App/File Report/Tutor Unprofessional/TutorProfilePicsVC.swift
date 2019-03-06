//
//  TutorProfilePics.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorProfilePicsView: FileReportSubmissionLayout {
    override func configureView() {
        super.configureView()

        header.text = "My tutor didn't match their profile picture(s)"

        textBody.font = Fonts.createSize(14)
        textBody.text = "Upon registration, every learner and QuickTutor is required to upload a profile picture, which helps both users recognize each other when meeting for in-person tutoring sessions.\n\nIf you believe that your tutor for this session was not who you were expecting, please notify us here.\n"
    }
}

class TutorProfilePicsVC: SubmissionViewControllerVC {
    override var contentView: TutorProfilePicsView {
        return view as! TutorProfilePicsView
    }

    var datasource: UserSession! {
        didSet {
            print("didSet")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "File Report"
        hideKeyboardWhenTappedAround()
    }

    override func loadView() {
        view = TutorProfilePicsView()
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
            "type": FileReportLearner.DidNotMatch.rawValue,
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
}
