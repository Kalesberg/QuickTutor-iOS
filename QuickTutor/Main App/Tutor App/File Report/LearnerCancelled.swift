//
//  LearnerCancelled.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class LearnerCancelledView : FileReportCheckboxLayout {
	
	override func configureView() {
		super.configureView()
		header.label.text = "My Learner cancelled"
		
		textBody.font = Fonts.createSize(14)
		textBody.text = "As a tutor, you have the option to create a custom cancellation policy, which learners are subject to upon scheduling a session with you. However, you are also subject to your own custom cancellation policy (CCP).  \n\nIf your learner has disobeyed your custom cancellation policy, please let us know. Note that a session cancellation must be filed no earlier than 30 mins before the scheduled end of a session. And cannot be filed more than 7 days after the date of the scheduled session.\n "
		
		cb1.label.text = "Learner cancelled the session"
		cb2.label.text = "Learner left the session early"
		cb3.label.text = "Learner didn't show up"
	}
}

class LearnerCancelled : BaseViewController {
	
	override var contentView: LearnerCancelledView {
		return view as! LearnerCancelledView
	}
	
	var type = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidLayoutSubviews() {
		
	}
	
	override func loadView() {
		view = LearnerCancelledView()
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
		
		let node = FileReportClass.TutorCancelled.rawValue
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
				return "Tutor cancelled the session"
			}
			return nil
		case 2:
			if contentView.cb2.checkbox.isSelected {
				return "Tutor left the session early"
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
