//
//  TutorDidNotHelp.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorDidNotHelpView: FileReportYesNoLayout {
    override func configureView() {
        super.configureView()
        header.text = "My tutor didn't help me"

        textBody.font = Fonts.createSize(14)
        textBody.text = "QuickTutor is committed to ensure quality tutoring for everyone. While anyone can be a tutor, we have instilled a strict rating and reviewing system in order to police the quality of QuickTutors and ensure learner satisfaction.\n\nPlease utilize the post-session rating and reviewing system to your full capability so you can ensure quality learning for others. Give tutors the rating you feel they deserve, and refer to our Learner Handbook in the Help menu for any questions regarding rating and reviewing tutors.\n\n\n"
    }

    override func applyConstraints() {
        super.applyConstraints()
    }

    override func layoutSubviews() {
        statusbarView.backgroundColor = Colors.learnerPurple
        navbar.backgroundColor = Colors.learnerPurple
    }
}

class TutorDidNotHelpVC: BaseViewController {
    override var contentView: TutorDidNotHelpView {
        return view as! TutorDidNotHelpView
    }

    var datasource: UserSession! {
        didSet {
            print("datasource set")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        view = TutorDidNotHelpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func handleNavigation() {
        if touchStartView == contentView.yesButton {
            wasHelpful(true)
        } else if touchStartView == contentView.noButton {
            wasHelpful(false)
        }
    }

    private func wasHelpful(_ bool: Bool) {
        let value: [String: Any] = [
            "reportee": datasource.otherId,
            "reason": "Was helpful:  \(bool)",
            "type": FileReportLearner.TutorDidNotHelp.rawValue,
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
