//
//  Learner.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class LearnerProfilePicsView : FileReportSubmissionLayout {
    
    override func configureView() {
        super.configureView()
        
        title.label.text = "File Report"
        header.text = "My Learner didn't match their profile picture(s)"
        
        textBody.font = Fonts.createSize(14)
        textBody.text = "Upon registration, every learner and QuickTutor is required to upload a profile picture, which helps both users recognize each other when meeting for in-person tutoring sessions.\n\nIf you believe that your learner for this session was not who you were expecting, please notify us here."
    }
    
    override func applyConstraints() {
        super.applyConstraints()
    }
}

class LearnerProfilePics : SubmissionViewController {
    
    override var contentView: LearnerProfilePicsView {
        return view as! LearnerProfilePicsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
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
            if contentView.textView.textView.text!.count > 20 {
                submitReport()
            } else {
                print("Please give us a breif description of what happened.")
            }
        }
    }
    
    private func submitReport() {
        
        let node = FileReportClass.DidNotMatch.rawValue
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
