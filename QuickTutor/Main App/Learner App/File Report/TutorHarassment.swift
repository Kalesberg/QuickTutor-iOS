//
//  TutorHarassment.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorHarassmentView : FileReportSubmissionLayout {
	
    override func configureView() {
        super.configureView()
        header.text = "Harassment"
        
        textBody.font = Fonts.createSize(14)
        textBody.text = "QuickTutor’s Non-Discrimination Policy is set in place to protect all users from harassment and ensure the safety of everyone using our platform.\n\nAggressive or inappropriate physical contact or verbal harassment is not tolerated. If your tutor did anything to make you feel uncomfortable, unsafe, or harassed you in any way, please let us know here."
    }
    
    override func applyConstraints() {
        super.applyConstraints()
    }
	override func layoutSubviews() {
		statusbarView.backgroundColor = Colors.learnerPurple
		navbar.backgroundColor = Colors.learnerPurple
	}
}

class TutorHarassment : SubmissionViewController {
    
    override var contentView: TutorHarassmentView {
        return view as! TutorHarassmentView
    }
	
	var datasource : UserSession! {
		didSet {
			print("Sessions.")
		}
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		hideKeyboardWhenTappedAround()
    }

	override func loadView() {
        view = TutorHarassmentView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
		if (touchStartView is SubmitButton) {
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
			"type" : FileReportLearner.Harassment.rawValue,
			"userType" : "learner",
			"name" : CurrentUser.shared.learner.name.split(separator: " ")[0],
			"email" : CurrentUser.shared.learner.email
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

