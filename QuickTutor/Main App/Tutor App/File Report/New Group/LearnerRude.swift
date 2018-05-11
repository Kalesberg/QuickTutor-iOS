//
//  LearnerRude.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class LearnerRudeView : FileReportSubmissionLayout {
    
    override func configureView() {
        super.configureView()
        header.text = "My learner was rude"
        
        textBody.font = Fonts.createSize(14)
        textBody.text = "QuickTutor has a zero tolerance policy for learners who are rude/unprofessional to their tutors. As a tutor, your feedback on sessions, including ratings and reviews helps us improve session quality for others.\n\nAll users agree to a high standard of service that includes being polite, professional, and respectful. If you believe your learner has been unprofessional, please share your experience."
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
    }
}

class LearnerRude : SubmissionViewController {
    
    override var contentView: LearnerRudeView {
        return view as! LearnerRudeView
    }
    
    var automaticScroll = false
    
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
            if contentView.textView.textView.text!.count > 20 {
                submitReport()
            } else {
                print("Please give us a breif description of what happened.")
            }
        }
    }
    private func submitReport() {
        
        let node = FileReportClass.TutorRude.rawValue
        let value : [String : Any] = ["reason" : contentView.textView.textView.text!]
        
        FirebaseData.manager.fileReport(sessionId: "SessionID1231", reportClass: node, value: value) { (error) in
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
