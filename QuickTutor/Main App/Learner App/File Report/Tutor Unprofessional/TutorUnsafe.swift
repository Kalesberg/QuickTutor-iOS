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
}

class TutorUnsafe : SubmissionViewController {
    
    override var contentView: TutorUnsafeView {
        return view as! TutorUnsafeView
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
		
		let node = FileReportClass.TutorUnsafe.rawValue
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
