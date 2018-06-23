//
//  Sessions.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class SessionsView : MainLayoutHeaderScroll {
    
    var requestingSessionsBody = SectionBody()
    var sendRequestSubtitle = SectionSubTitle()
    var sendRequestBody = SectionBody()
    var sendRequestBody2 = SectionBody()
    var startingSessionsTitle = SectionTitle()
    var startingSessionsBody = SectionBody()
    var automaticSessionsTitle = SectionTitle()
    var automaticSessionsBody = SectionBody()
    var startingTitle = SectionTitle()
    var startingBody = SectionBody()
    var inSessionTitle = SectionTitle()
    var inSessionBody = SectionBody()
    var postSessionTitle = SectionTitle()
    var postSessionBody = SectionBody()
    var strings: [String] = []
    
    override func configureView() {
        scrollView.addSubview(requestingSessionsBody)
        scrollView.addSubview(sendRequestSubtitle)
        scrollView.addSubview(sendRequestBody)
        scrollView.addSubview(sendRequestBody2)
        scrollView.addSubview(startingSessionsTitle)
        scrollView.addSubview(startingSessionsBody)
        scrollView.addSubview(automaticSessionsTitle)
        scrollView.addSubview(automaticSessionsBody)
        scrollView.addSubview(startingTitle)
        scrollView.addSubview(startingBody)
        scrollView.addSubview(inSessionTitle)
        scrollView.addSubview(inSessionBody)
        scrollView.addSubview(postSessionTitle)
        scrollView.addSubview(postSessionBody)
        super.configureView()
        
        title.label.text = "Sessions"
        header.label.text = "Requesting Sessions"
        
        requestingSessionsBody.text = "Once you have connected with a tutor, you can send session requests. Session requests can be scheduled as early as fifteen minutes in the future, and up to thirty days in advance. "
        
        sendRequestSubtitle.label.text = "There are two ways to send a session request:"
        
        strings = ["1.  Tapping the “+” icon in your messages with a tutor, selecting the “Request Session” button, and then filling in the session details.\n\n", "2.  Selecting the “Request Session” button in the bottom right of the “Sessions” tab in messenger, selecting a tutor, and then filling in the session details.\n"]
        
		let attributesDictionary : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : sendRequestBody.font]
        let fullAttributedString = NSMutableAttributedString(string: "", attributes: attributesDictionary)
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        sendRequestBody.attributedText = fullAttributedString
        
        sendRequestBody2.text = "Session requests that have not yet been accepted will appear under the “Pending” section in the “Sessions” tab of your messenger. They will remain here until a tutor accepts your session request. Once accepted, they will appear under the “Upcoming” section in the “Sessions” tab."
        
        startingSessionsTitle.label.text = "Manually starting sessions"
        startingSessionsBody.text = "Sometimes you and a tutor may agree to start your session before the scheduled time. Both you or your tutor can manually start sessions by going to the “Sessions” tab, tapping on the particular session in the “Upcoming” section, and then tapping “Start”.\n\nOnce you manually start a session, the tutor will have to accept your manual start before the session can occur."
        
        automaticSessionsTitle.label.text = "Automatic starting sessions"
        automaticSessionsBody.text = "When it is time for a session to begin, it will simply begin."
        
        startingTitle.label.text = "Sessions starting"
        startingBody.text = "Whether your session is started manually or automatically — if you are outside of the app, you will receive a push notification that will take you into the session menu. If you are inside the app when your session is manually or automatically started, you will be taken directly to the session menu.\n\nVideo (online) tutoring sessions begin automatically when accepted. If your session is in-person, you and your tutor will both be asked to confirm the meet-up. Once the meet-up is confirmed by both you and your tutor, your session will begin and you will start being charged for tutoring."
        
        inSessionTitle.label.text = "In-Session"
        inSessionBody.text = "In-person and online/video QuickTutor sessions are exactly the same. Both tutors and learners can leave or pause sessions at anytime. You can pause a session by tapping on the “||” symbol. Learners are not penalized for leaving sessions early. Tutors are subject to disciplinary action if leaving sessions early becomes a trend.\n\nYou can report a tutor for canceling, being late to a session, or leaving a session early in the “File Report” tab of the settings bar.\n\nWhen a session’s time is up, we will ask you if you’d like to keep going or end the session immediately.\n\nIf you choose to keep going, you have the option to choose how much more time the session will be. A tutor will have to accept this time addition on their end, and then the session can continue. If a tutor denies the time addition, the session ends immediately."
        
        postSessionTitle.label.text = "Post-Session"
        postSessionBody.text = "After a session, you will be asked if you would like to tip your tutor. While tips are a very generous way of gifting your tutor, they are not mandatory.\n\nAfter a session, you will also be asked to rate and review your tutor. When rating and reviewing a tutor, please remember to be honest and leave an accurate review — this will help other learners, increase the QuickTutor platform quality, and get rid of fraud tutors. Ratings and reviews are extremely important and should be taken seriously.\n\n"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        requestingSessionsBody.constrainSelf(top: header.snp.bottom)
        sendRequestSubtitle.constrainSelf(top: requestingSessionsBody.snp.bottom)
        sendRequestBody.constrainSelf(top: sendRequestSubtitle.snp.bottom)
        sendRequestBody2.constrainSelf(top: sendRequestBody.snp.bottom)
        startingSessionsTitle.constrainSelf(top: sendRequestBody2.snp.bottom)
        startingSessionsBody.constrainSelf(top: startingSessionsTitle.snp.bottom)
        automaticSessionsTitle.constrainSelf(top: startingSessionsBody.snp.bottom)
        automaticSessionsBody.constrainSelf(top: automaticSessionsTitle.snp.bottom)
        startingTitle.constrainSelf(top: automaticSessionsBody.snp.bottom)
        startingBody.constrainSelf(top: startingTitle.snp.bottom)
        inSessionTitle.constrainSelf(top: startingBody.snp.bottom)
        inSessionBody.constrainSelf(top: inSessionTitle.snp.bottom)
        postSessionTitle.constrainSelf(top: inSessionBody.snp.bottom)
        postSessionBody.constrainSelf(top: postSessionTitle.snp.bottom)
    }
}


class Sessions : BaseViewController {
    
    override var contentView: SessionsView {
        return view as! SessionsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }
    
    override func loadView() {
        view = SessionsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        
    }
}
