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
        header.label.text = "My learner made me feel unsafe"

        textBody.font = Fonts.createSize(14)
        textBody.text = "QuickTutor possess strict safety guidelines to keep your tutoring session as safe and comfortable as possible.\n\nRude, aggressive, or inappropriate physical contact or verbal aggression is not tolerated. If your learner did anything to make you feel uncomfortable or unsafe, please let us know here. "
    }
}

class LearnerUnsafe: SubmissionViewController {
    override var contentView: LearnerUnsafeView {
        return view as! LearnerUnsafeView
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
            if contentView.textView.textView.text!.count > 20 {
                submitReport()
            } else {
                print("Please give us a breif description of what happened.")
            }
        }
    }

    private func submitReport() {
        let node = FileReportClass.TutorUnsafe.rawValue
        let value: [String: Any] = ["reason": contentView.textView.textView.text!]

        FirebaseData.manager.fileReport(sessionId: "SessionID1231", reportClass: node, value: value) { error in
            if let error = error {
                print(error)
            } else {
                self.customerServiceAlert {
                    self.navigationController?.popBackToMain()
                }
            }
        }
    }
}
