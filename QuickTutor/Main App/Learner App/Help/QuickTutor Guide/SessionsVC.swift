//
//  SessionsVC.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class SessionsView: MainLayoutHeaderScroll {
    var requestingSessionsBody = SectionBody()
    var sendRequestSubtitle = SectionSubTitle()
    var sendRequestBody = SectionBody()
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

        header.label.text = "Requesting Sessions"

        requestingSessionsBody.text = "Once you have connected with a tutor, you can send session requests. Session requests can be scheduled as early as fifteen minutes in the future, and up to thirty days in advance.\n\nAlthough a tutor has a set hourly rate, you can negotiate with them in the messaging system and schedule a session for any price up to $12,000, at a maximum session length of 12 hours."

        sendRequestSubtitle.label.text = "How to schedule a tutoring session:"

        sendRequestBody.text = "Tap the \"+\" icon in the bottom left of your messages with a tutor, select the “Request Session” button, and then fill in the session details and tap the “Send” button at the bottom.\n\nThe session request will then be sent to the tutor, and it will say \"pending\" until it is accepted by the tutor. You can find your pending session requests under the \"Pending\" section in the \"Sessions\" tab of your messenger."

        startingSessionsTitle.label.text = "Manually starting sessions"
        startingSessionsBody.text = "Sometimes you and a tutor may agree to start your session before the scheduled time. Both you or your tutor can attempt to manually start tutoring sessions by going to the \"Sessions\" tab in your messenger, tapping on the particular session in the \"Upcoming\" section, and then tapping the green \"Start\" button.\n\nOnce you press the start button it will notify your tutor. The tutor will have to accept your manual start before the session starts. Once the tutor accepts the manual start request, the session will begin instantly."

        automaticSessionsTitle.label.text = "Automatic starting sessions"
        automaticSessionsBody.text = "When it is time for a session to begin, it will simply begin."

        startingTitle.label.text = "Sessions starting"
        startingBody.text = "Whether your session is started manually or automatically — if you are outside of the app, you will receive a push notification that will take you into the session menu.\n\nVideo (online) tutoring sessions begin automatically when accepted by both users.\n\nIf your session is in-person, you and your tutor will both be asked to confirm the meet-up. Once the meet-up is confirmed by both you and your tutor, your session will begin and you will begin being charged for tutoring. "

        inSessionTitle.label.text = "In-Session"
        inSessionBody.text = "In-person and online/video sessions are exactly the same. Both tutors and learners can pause or leave sessions at anytime. When a session is paused — the clock is completely stopped, learners are not being charged and tutors are not being paid while a session is paused. You can pause a session by tapping on the \"||\" icon in the top left of the screen during both video call and in-person sessions.\n\nLearners are not penalized for leaving sessions early. Tutors may be subject to disciplinary if leaving sessions becomes a consistent occurrence.\n\nYou can report a tutor for canceling, being late or leaving a session early in the \"File Report\" tab of the side bar menu.\n\nWhen a session’s time is up, we will ask you whether you’d like to keep the session going or end it immediately.\n\nIf you choose to keep going, you have the option to choose how much more time the session will be. A tutor will have to accept your time addition on their end, and then the session can continue. If a tutor denies the time addition — the session will end. "

        postSessionTitle.label.text = "Post-Session"
        postSessionBody.text = "After a session, you will be asked if you would like to tip your tutor. While tips are a very generous way of gifting your tutor, they are not mandatory.\n\nAfter a session, you will also be asked to rate and write a review on your tutor. When rating and reviewing a tutor, please remember to be honest and leave an accurate review — this will help other learners, increase the quality of the QuickTutor platform, and get rid of fraudulent tutors. Ratings and reviews are extremely important and should be taken seriously.\n\n"
    }

    override func applyConstraints() {
        super.applyConstraints()

        requestingSessionsBody.constrainSelf(top: header.snp.bottom)
        sendRequestSubtitle.constrainSelf(top: requestingSessionsBody.snp.bottom)
        sendRequestBody.constrainSelf(top: sendRequestSubtitle.snp.bottom)
        startingSessionsTitle.constrainSelf(top: sendRequestBody.snp.bottom)
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

class SessionsVC: BaseViewController {
    override var contentView: SessionsView {
        return view as! SessionsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sessions"
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = SessionsView()
    }

    override func handleNavigation() {}
}
