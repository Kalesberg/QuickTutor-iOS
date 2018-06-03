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
        header.text = "Other"
        
        textBody.font = Fonts.createSize(14)
        textBody.text = "QuickTutor's mission is to ensure all learners have the best experience possible. Tell us what happened during your session and we'll do our best to make sure it doesn't happen again. Refer to the Learner Handbook for more information."
    }
    
    override func applyConstraints() {
        super.applyConstraints()
    }
	override func layoutSubviews() {
		statusbarView.backgroundColor = Colors.learnerPurple
		navbar.backgroundColor = Colors.learnerPurple
	}
}

class TutorOther : SubmissionViewController {
    
    override var contentView: TutorOtherView {
        return view as! TutorOtherView
    }
	
	var datasource : UserSession! {
		didSet {
			print("datasource set.")
		}
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
            if contentView.textView.textView.text!.count < 20 {
                contentView.errorLabel.isHidden = false
            } else {
                contentView.errorLabel.isHidden = true
                submitReport()
            }
		}
	}
	
	private func submitReport() {
		
		let value : [String : Any] = [
			"reportee" : datasource.otherId,
			"reason" : contentView.textView.textView.text,
			"type" : FileReportClass.TutorCancelled.rawValue,
			]
		
		FirebaseData.manager.fileReport(sessionId: datasource.id, reportStatus: datasource.reportStatus.reportStatusUpdate(type: "learner"), value: value) { (error) in
			if error != nil {
				AlertController.genericErrorAlert(self, title: "Error Filing Report", message: "Something went wrong, please try again.")
			} else{
				self.customerServiceAlert {
					self.navigationController?.popBackToMain()
				}
			}
		}
	}
}
