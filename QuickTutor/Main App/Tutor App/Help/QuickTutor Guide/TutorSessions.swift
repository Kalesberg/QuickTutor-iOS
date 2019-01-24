//
//  TutorSessions.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorSessionsView: MainLayoutHeaderScroll {
    var acceptSessionBody = SectionBody()
    var twoWaysSubtitle = SectionSubTitle()
    var twoWaysBody = SectionBody()
    var manualStartTitle = SectionTitle()
    var manualStartBody = SectionBody()
    var automaticStartTitle = SectionTitle()
    var automaticStartBody = SectionBody()
    var sessionStartTitle = SectionTitle()
    var sessionStartBody = SectionBody()
    var inSessionTitle = SectionTitle()
    var inSessionBody = SectionBody()
    var postSessionTitle = SectionTitle()
    var postSessionBody = SectionBody()
    var strings: [String] = []

    override func configureView() {
        scrollView.addSubview(acceptSessionBody)
        scrollView.addSubview(twoWaysSubtitle)
        scrollView.addSubview(twoWaysBody)
        scrollView.addSubview(manualStartTitle)
        scrollView.addSubview(manualStartBody)
        scrollView.addSubview(automaticStartTitle)
        scrollView.addSubview(automaticStartBody)
        scrollView.addSubview(sessionStartTitle)
        scrollView.addSubview(sessionStartBody)
        scrollView.addSubview(inSessionTitle)
        scrollView.addSubview(inSessionBody)
        scrollView.addSubview(postSessionTitle)
        scrollView.addSubview(postSessionBody)
        super.configureView()

        header.label.text = "Accepting session requests"

        acceptSessionBody.text = "Once you have accepted a learner’s connection request through the messaging system, they can send session requests. Session requests can be scheduled as early as fifteen minutes in the future, and up to thirty days in advance.\n"

        twoWaysSubtitle.label.text = "There are two ways to accept a session request:"

        strings = ["1.  Tapping the “accept” button on a session request in the particular message thread it was sent in.\n\n", "2.  Tapping on a session in the “Requests” section of your “Sessions” tab, and then selecting: “accept”. "]

        let attributesDictionary: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: acceptSessionBody.font]
        let fullAttributedString = NSMutableAttributedString(string: "", attributes: attributesDictionary)

        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)

            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))

            fullAttributedString.append(attributedString)
        }

        twoWaysBody.attributedText = fullAttributedString

        manualStartTitle.label.text = "Manually Starting Sessions"

        manualStartBody.text = "Sometimes you and a learner may agree to start your session before the scheduled time. Both you and your learner can manually start sessions by going to the “Sessions” tab, tapping on the particular session in the “Upcoming” section, and then tapping “Start”.\n\nOnce you manually start a session, the learner will have to accept your manual start before the session can occur."

        automaticStartTitle.label.text = "Automatic starting sessions"

        automaticStartBody.text = "When it is time for a session to begin, it will simply begin."

        sessionStartTitle.label.text = "Sessions starting"

        sessionStartBody.text = "Whether your session is started manually or automatically — If you are outside of the app, you will receive a push notification that will take you into the session menu. If you are inside the app when your session is manually or automatically started, you will be taken directly to the session menu.\n\nVideo (online) tutoring sessions begin automatically when accepted.If your session is in-person, you and your learner will both be asked to confirm the meet-up. Once the meet-up is confirmed, your session will begin."

        inSessionTitle.label.text = "In-Session"

        inSessionBody.text = "In-person and online/video QuickTutor sessions are exactly the same. Both tutors and learners can leave or pause sessions at anytime. You can pause a session by tapping on the “||” symbol. Learners are not penalized for leaving sessions early. Tutors are subject to disciplinary action if leaving sessions early becomes a trend.\n\nYou can report a learner for canceling, being late to a session, or not showing up to a session in the “File Report” tab of the settings bar.\n\nWhen a session’s time is up, we will ask your learner if they would like to keep going or end the session immediately. You can choose to end the session immediately and override the learner’s choice at any time.\n\nIf your learner decides to add time, you have the option to accept or deny the added time request. If you deny the time addition, the session ends immediately. "

        postSessionTitle.label.text = "Post-session"

        postSessionBody.text = "After a session, your learner will be asked if they would like to tip you. While tips are a very generous way of giving — tips are not mandatory, nor should tutors aggressively ask for tips.\n\nAfter a session, you will be asked to rate and review your learner. When rating and reviewing a learner, please remember to be honest and leave an accurate review — this will help other tutors, increase the QuickTutor platform quality, and get rid of trouble-making learners. Ratings and reviews are extremely important and should be taken seriously.\n\n"
    }

    override func applyConstraints() {
        super.applyConstraints()

        acceptSessionBody.constrainSelf(top: header.snp.bottom)
        twoWaysSubtitle.constrainSelf(top: acceptSessionBody.snp.bottom)
        twoWaysBody.constrainSelf(top: twoWaysSubtitle.snp.bottom)
        manualStartTitle.constrainSelf(top: twoWaysBody.snp.bottom)
        manualStartBody.constrainSelf(top: manualStartTitle.snp.bottom)
        automaticStartTitle.constrainSelf(top: manualStartBody.snp.bottom)
        automaticStartBody.constrainSelf(top: automaticStartTitle.snp.bottom)
        sessionStartTitle.constrainSelf(top: automaticStartBody.snp.bottom)
        sessionStartBody.constrainSelf(top: sessionStartTitle.snp.bottom)
        inSessionTitle.constrainSelf(top: sessionStartBody.snp.bottom)
        inSessionBody.constrainSelf(top: inSessionTitle.snp.bottom)
        postSessionTitle.constrainSelf(top: inSessionBody.snp.bottom)
        postSessionBody.constrainSelf(top: postSessionTitle.snp.bottom)
    }
}

class TutorSessions: BaseViewController {
    override var contentView: TutorSessionsView {
        return view as! TutorSessionsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sessions"
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = TutorSessionsView()
    }

}
