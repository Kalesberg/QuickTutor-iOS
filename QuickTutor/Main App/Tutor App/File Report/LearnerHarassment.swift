//
//  LearnerHarassment.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class LearnerHarassmentView : FileReportSubmissionLayout {
	
	override func configureView() {
		super.configureView()
		header.text = "Harassment"
		
		textBody.font = Fonts.createSize(14)
		textBody.text = "QuickTutor’s Non-Discrimination Policy is set in place to protect all users from harassment and ensure the safety of everyone using our platform.\n\nAggressive or inappropriate physical contact or verbal harassment is not tolerated. If your learner did anything to make you feel uncomfortable, unsafe, or harassed you in any way, please let us know here.\n"
	}
	
	override func applyConstraints() {
		super.applyConstraints()
	}
}

class LearnerHarassment : SubmissionViewController {
	
	override var contentView: LearnerHarassmentView {
		return view as! LearnerHarassmentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		hideKeyboardWhenTappedAround()
	}
	
	override func loadView() {
		view = LearnerHarassmentView()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func handleNavigation() {
		if (touchStartView is SubmitButton) {
			if contentView.textView.textView.text!.count > 20 {
				submitReport()
			} else {
				print("Please give us a breif description of what happened.")
			}
		}
	}
	
	private func submitReport() {
		let node = FileReportClass.Harassment.rawValue
		let value : [String : Any] = ["reason" : contentView.textView.textView.text!]
		
		FirebaseData.manager.fileReport(sessionId: "SessionID1231", reportClass: node, value: value) { (error) in
			if error != nil {
				AlertController.genericErrorAlert(self, title: "Error Processing Report", message: "Something went wrong, please try again")
				self.customerServiceAlert {
					self.navigationController?.popBackToMain()
				}
			}
		}
	}
}
