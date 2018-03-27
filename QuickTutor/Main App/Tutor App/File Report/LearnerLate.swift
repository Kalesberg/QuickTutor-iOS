//
//  TutorLate.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class LearnerLateView : FileReportCheckboxLayout {
    
    override func configureView() {
        super.configureView()
        header.label.text = "My Learner was late"
        
        textBody.font = Fonts.createSize(14)
        textBody.text = "As a tutor, you have the option to create your own custom cancellation policy (CCP) -- which learners are subject to upon scheduling a session with you. This includes late fees. However, as a tutor you are subject to your own policy as well.\n\nIf your learner disobeyed your late policy, please let us know. Note that a report must be filed no earlier than 30 mins before the scheduled end of a session. And cannot be filed more than 7 days after the date of the scheduled session.\n"
        
        cb1.label.text = "Learner arrived late"
        cb2.label.text = "Learner arrived extensively late"
        cb3.label.text = "Lerner didn't show up"
    }
}

class LearnerLate : BaseViewController {
    
    override var contentView: LearnerLateView {
        return view as! LearnerLateView
    }
    var type = 0
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func loadView() {
        view = LearnerLateView()
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
            print("Select an option!")
            return
        }
        
        let node = FileReportClass.TutorLate.rawValue
        let value : [String : Any] = ["reason" : reason]
        
        FirebaseData.manager.fileReport(sessionId: "SessionID1231", reportClass: node, value: value) { (error) in
            if let error = error{
                print(error)
            } else{
                print("Submitted!")
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
