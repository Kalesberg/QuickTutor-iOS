//
//  TutorOther.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorOtherView : FileReportSubmissionLayout {
    
    override func configureView() {
        super.configureView()
        header.label.text = "Other"
        
        textBody.font = Fonts.createSize(14)
        textBody.text = "QuickTutor's mission is to ensure all learners have the best experience possible. Tell us what happened during your session and we'll do our best to make sure it doesn't happen again. Refer to the Learner Handbook for more information."
    }
    
    override func applyConstraints() {
        super.applyConstraints()
    }
}

class TutorOther : SubmissionViewController {
    
    override var contentView: TutorOtherView {
        return view as! TutorOtherView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		hideKeyboardWhenTappedAround()
    }

    override func loadView() {
        view = TutorOtherView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	override func handleNavigation() {
		if touchStartView == contentView.submitButton {
			if contentView.textView.textView.text!.count > 20 {
				submitReport()
			} else {
				print("Please give us a breif description of what happened.")
			}
		}
	}
	
	private func submitReport() {
		
		let node = FileReportClass.Other.rawValue
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
