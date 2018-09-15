//
//  Tutor Rude.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorRudeView : FileReportSubmissionLayout {
    
    override func configureView() {
        super.configureView()
        header.text = "My tutor was rude"
        
        textBody.font = Fonts.createSize(14)
        textBody.text = "QuickTutor has a zero tolerance policy for tutors who are unprofessional/rude to their learners. \n\nAs a learner, your feedback on sessions, including ratings and reviews, helps us improve session quality for others. All tutors agree to a high standard of service that includes being polite, professional, and respectful. If you believe your tutor has been unprofessional, please share your experience."
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
    }
	override func layoutSubviews() {
		statusbarView.backgroundColor = Colors.learnerPurple
		navbar.backgroundColor = Colors.learnerPurple
	}
}

class TutorRude : SubmissionViewController {
    
    override var contentView: TutorRudeView {
        return view as! TutorRudeView
    }
    
    var automaticScroll = false
	
	var datasource : UserSession! {
		didSet {
			print("datasource set.")
		}
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		hideKeyboardWhenTappedAround()
        contentView.layoutIfNeeded()
    }
	
    override func loadView() {
        view = TutorRudeView()
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
		
		let value : [String : Any] = [
			"reportee" : datasource.otherId,
			"reason" : contentView.textView.textView.text,
			"type" : FileReportLearner.TutorRude.rawValue,
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
