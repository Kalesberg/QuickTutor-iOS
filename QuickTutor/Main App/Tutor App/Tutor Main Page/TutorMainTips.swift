//
//  TutorTips.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorMainTipsView : MainLayoutTitleBackButton {
    
    let textView : UITextView = {
        let textView = UITextView()
		
        textView.showsVerticalScrollIndicator = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("How to Connect with Learners\n", 16, .white)
            .regular("\n", 8, .clear)
            .regular("Once you build a profile, you wait for learners to send you connection requests. You can increase your chances of receiving more connection requests by adding as many subjects as you are capable of tutoring to your profile, under \"edit profile.\"\n\n", 15, Colors.grayText)
            .bold("Adjust up Preferences\n", 16, .white)
            .regular("\n", 8, .clear)
            .regular("Your preferences are your hourly price as a tutor, whether you'd like to do video calling sessions, and how far you'd want to travel for tutoring. You set them up in registration when you first made your account. You can adjust your preferences by selecting the \"edit profile\" button on your profile (top right).\n\n", 15, Colors.grayText)
            .bold("Increase Learner Connection Requests\n", 16, .white)
            .regular("\n", 8, .clear)
            .regular("You can increase the number of learner requests you receive by setting up your policies, adding more subjects to your profile, uploading more than one profile picture, or increasing the amount of detail in your biography so that learners know you're the real deal.\n\n", 15, Colors.grayText)
            .bold("Set Up Policies\n", 16, .white)
            .regular("\n", 8, .clear)
            .regular("You can set up your policies as a QuickTutor in \"edit profile\" which includes:\n\n- Custom Cancellation Policy (CCP).\n- Late Fee Policy (your tolerance & fee for learners being late).\n\n", 15, Colors.grayText)
            .bold("Getting More Learners\n", 16, .white)
            .regular("\n", 8, .clear)
            .regular("The QuickTutor marketplace is structured to ensure that learners can find the best tutors and that active tutors receive learner leads with a high connection rate. A few things that will improve your connection rate are your tutor rating, tutoring history, learner reviews, and how much information you include on your profile. \n\n", 15, Colors.grayText)
        
        textView.attributedText = formattedString
        
        return textView
    }()
    
    override func configureView() {
        addSubview(textView)
        super.configureView()
        
        title.label.text = "Tutor Tips"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        textView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.top.equalTo(navbar.snp.bottom).inset(-20)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
            make.centerX.equalToSuperview()
        }
    }
}

class TutorMainTips : BaseViewController {
    
    override var contentView: TutorMainTipsView {
        return view as! TutorMainTipsView
    }
    override func loadView() {
        view = TutorMainTipsView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.textView.setContentOffset(.zero, animated: false)
    }
}
