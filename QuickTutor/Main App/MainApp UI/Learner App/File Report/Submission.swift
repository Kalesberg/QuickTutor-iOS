//
//  Submission.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/29/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit



fileprivate class SubmissionViewController : BaseViewController {
	
	override func viewWillAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDisappear), name: Notification.Name.UIKeyboardDidHide, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
	}
	
	@objc func keyboardWillAppear() {
		if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
			(self.view as! FileReportSubmissionLayout).keyboardWillAppear()
		}
	}
	
	@objc func keyboardDidDisappear() {
		if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
			(self.view as! FileReportSubmissionLayout).keyboardDidDisappear()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self)
	}
	
	func checkReport() {
		let view = (self.view as! FileReportSubmissionLayout)
		if view.textView.textView.text!.count < 20 {
			view.errorLabel.isHidden = false
		} else {
			view.errorLabel.isHidden = true
		}
	}
}
