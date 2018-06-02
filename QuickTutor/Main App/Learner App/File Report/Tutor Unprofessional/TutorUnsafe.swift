//
//  TutorUnsafe.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorUnsafeView : FileReportSubmissionLayout {
    
    override func configureView() {
        super.configureView()
        header.text = "My tutor made me feel unsafe"
        
        textBody.font = Fonts.createSize(14)
        textBody.text = "QuickTutor possess strict safety guidelines to keep your tutoring session as safe and comfortable as possible.\n\nRude, aggressive, or inappropriate physical contact or verbal aggression is not tolerated. If your tutor did anything to make you feel uncomfortable or unsafe, please let us know here. "
    }
    
    override func applyConstraints() {
        super.applyConstraints()
    }
	override func layoutSubviews() {
		statusbarView.backgroundColor = Colors.learnerPurple
		navbar.backgroundColor = Colors.learnerPurple
	}
}

class TutorUnsafe : SubmissionViewController {
    
    override var contentView: TutorUnsafeView {
        return view as! TutorUnsafeView
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
        view = TutorUnsafeView()
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
			"type" : FileReportClass.TutorCancelled.rawValue,
			]
		
		FirebaseData.manager.fileReport(sessionId: datasource.id, value: value) { (error) in
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
