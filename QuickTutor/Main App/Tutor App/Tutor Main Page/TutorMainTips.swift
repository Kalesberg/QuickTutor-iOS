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
            .bold("How to connect with learners\n", 16, .white)
            .regular("\n", 8, .clear)
            .regular("Once you complete initial registration, you still have to establish three preferences before you can connect with learners.\n\n", 15, Colors.grayText)
            .bold("Set up preferences\n", 16, .white)
            .regular("\n", 8, .clear)
            .regular("1.  Your hourly price as a tutor.\n2.  If you’d like to do online (video call) tutoring.\n3.  If you’d like to travel & how far you’d travel for tutoring.\n\n", 15, Colors.grayText)
            .bold("Increase learner connection requests\n", 16, .white)
            .regular("\n", 8, .clear)
            .regular("You can increase the amount of learner requests you receive by setting up your policies, availability, and/or inserting courses you’ve completed at university, etc.\n", 15, Colors.grayText)
            .regular("\n", 8, .clear)
            .bold("1.  Set up policies\n", 16, .white)
            .regular("\nYou can setup your own policies as a QuickTutor in the tutor menu, which includes:\n\n- Custom Cancellation Policy (CCP).\n- Late Fee Policy (your tolerance & fee for learners being late).\n\n", 15, Colors.grayText)
            .bold("2.  Set up availability\n", 16, .white)
            .regular("\nYou can also set your availability in the tutor menu. This will allow learners to know when you’re usually available to schedule sessions.\n\n", 15, Colors.grayText)
            .bold("Increase learner trust\n", 16, .white)
            .regular("\nYou can increase learner trust by uploading more than one profile picture and connecting your QuickTutor account to Instagram.\n\n", 15, Colors.grayText)
            .bold("Getting more learners\n", 16, .white)
            .regular("\nThe QuickTutor marketplace is structured to ensure that learners can find the best tutors, and that active tutors receive learner leads with a high connection rate. A few things that will improve your connection rate are your tutor rating, tutoring history, learner reviews, and how much information you include on your profile.\n\n", 15, Colors.grayText)
        
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
            make.bottom.equalTo(safeAreaLayoutGuide)
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
