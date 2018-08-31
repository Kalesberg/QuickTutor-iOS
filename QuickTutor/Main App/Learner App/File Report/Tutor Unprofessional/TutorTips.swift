//
//  TutorTips.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorTipsView : FileReportYesNoLayout {
    
    override func configureView() {
        super.configureView()
        
        header.text = "Is my tutor allowed to ask for tips?"
        
        textBody.font = Fonts.createSize(14)
        textBody.text = "Tutors who operate through QuickTutor are independent contractors and may request tips.\n\nPlease note that the session fare charged to your account does not include gratuity. QuickTutor does not require learners to offer their tutor's tips, but you are welcome to do so if you please.\n\nIf you choose to tip, it is the tutors choice to accept or decline your gratuity. Tutors care about their ratings and reviews and will do their best to ensure your learning experience is ideal.\n\n"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
    }
	override func layoutSubviews() {
		statusbarView.backgroundColor = Colors.learnerPurple
		navbar.backgroundColor = Colors.learnerPurple
	}
}

class TutorTips : BaseViewController {
    
    override var contentView: TutorTipsView {
        return view as! TutorTipsView
    }
	var datasource : UserSession! {
		didSet {
			print("didSet")
		}
	}
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = TutorTipsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	override func handleNavigation() {
		if touchStartView == contentView.yesButton {
			wasHelpful(true)
		} else if touchStartView == contentView.noButton {
			wasHelpful(false)
		}
	}
	
	private func wasHelpful(_ bool : Bool) {
		let value : [String : Any] = [
			"reportee" : datasource.otherId,
			"reason" : "Was helpful:  \(bool)",
			"type" : FileReportLearner.TutorTips.rawValue,
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
