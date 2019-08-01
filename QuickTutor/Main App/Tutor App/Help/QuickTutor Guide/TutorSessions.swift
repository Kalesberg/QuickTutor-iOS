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
    var acceptSessionTitle = SectionTitle()
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
    var reportSessionTitle = SectionTitle()
    var reportSessionBody = SectionBody()
    var postSessionTitle = SectionTitle()
    var postSessionBody = SectionBody()
    var quickCallsTitle = SectionTitle()
    var quickCallsBody = SectionBody()
    var quickCallRateTitle = SectionTitle()
    var quickCallRateBody = SectionBody()
    
    var strings: [String] = []

    override func configureView() {
        scrollView.addSubview(acceptSessionTitle)
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
        scrollView.addSubview(reportSessionTitle)
        scrollView.addSubview(reportSessionBody)
        scrollView.addSubview(postSessionTitle)
        scrollView.addSubview(postSessionBody)
        scrollView.addSubview(quickCallsTitle)
        scrollView.addSubview(quickCallsBody)
        scrollView.addSubview(quickCallRateTitle)
        scrollView.addSubview(quickCallRateBody)
        
        super.configureView()

        header.label.text = "Session requests"
        acceptSessionTitle.label.text = "Accepting session requests"
        twoWaysSubtitle.label.text = "There are two ways to accept a session request:"

        strings = ["1,  Tapping the “accept” button on a session request in your messages.\n\n",
                      "2.  Tapping on a session in your “requests” section of your sessions tab (center, flame icon) and then tapping the “check” button."]
        var attributesDictionary: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: twoWaysBody.font]
        var fullAttributedString = NSMutableAttributedString(string: "", attributes: attributesDictionary)
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        twoWaysBody.attributedText = fullAttributedString

        manualStartTitle.label.text = "Manually starting sessions"

        manualStartBody.text = "Sometimes you and a user may agree to start your session before the scheduled start time. You or your client can manually start sessions by going to the \"Sessions tab\", tapping on the specific session in the \"Upcoming\" section, and then tapping the start button (checkmark icon)."

        automaticStartTitle.label.text = "Automatically starting sessions"

        automaticStartBody.text = "When it is time for a session to begin, it will simply begin. If you are outside of the application, it will send you a push notification, which when tapped on, will take you directly into the session. If the other user is not entering the session, you’ll have to wait on the start menu until they tap the push notification outside of their app or open the QuickTutor app."

        sessionStartTitle.label.text = "Starting sessions"

        sessionStartBody.text = "Whether your session is started manually or automatically — if you are outside of the app, you’ll receive a push notification that it is time to begin. If you are inside the app when your session is manually or automatically started, you will be taken directly to the session starting menu."

        inSessionTitle.label.text = "In-Session"

        inSessionBody.text = "In-person and online sessions operate similarly. Both users can pause or leave sessions at anytime. When a session is paused — the clock is completely stopped, users are not charged and tutors will not be compensated for this time. You can pause a session by tapping on the arrow button in the bottom left corner of your screen and then selecting \"pause session\".\n\nWhen a session’s time is up, we will ask the user if they would like to keep the session going or end it immediately. You can choose to end the session immediately and override your client’s choice at any time.\n\nIf your client decides to add time, you have the option to accept or deny the added time request. If you deny the time addition, the session ends immediately. "

        reportSessionTitle.label.text = "Community guidelines & reports"
        attributesDictionary = [.font: reportSessionBody.font]
        fullAttributedString = NSMutableAttributedString(string: "Users will not be penalized for leaving sessions early. You are subject to disciplinary action if leaving sessions early becomes a trend.\n\nYou can report a user for canceling, being late to a session, or not showing up to a session in your \"Past Transactions\" section on your profile tab.\n\n", attributes: attributesDictionary)
        fullAttributedString.append(NSAttributedString(string: "To file a report on a past session: \n\n", attributes: [.font: UIFont.qtBoldFont(size: 17)]))
        strings = ["1.  Tap the profile tab (profile icon) in the bottom right corner of your screen.\n",
            "2.  Select the \"past transactions\" from your profile tab option menu.\n",
            "3.  Tap the violet flag icon.\n",
            "4.  Fill out a report accurately to the best of your ability.\n\n"]
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        fullAttributedString.append(NSAttributedString(string: "We will respond to your report within 72 hours.\n\nVisit our ", attributes: attributesDictionary))
        fullAttributedString.append(NSAttributedString(string: "Community Guidelines", attributes: [.font: UIFont.qtBoldFont(size: 14), .foregroundColor: UIColor(hex: "6362C1")]))
        fullAttributedString.append(NSAttributedString(string: " or ", attributes: attributesDictionary))
        fullAttributedString.append(NSAttributedString(string: "Service Terms of Use", attributes: [.font: UIFont.qtBoldFont(size: 14), .foregroundColor: UIColor(hex: "6362C1")]))
        fullAttributedString.append(NSAttributedString(string: " to learn more about our rules, regulations and reportable in-app offenses.", attributes: attributesDictionary))
        reportSessionBody.attributedText = fullAttributedString
        
        postSessionTitle.label.text = "Post-session"

        postSessionBody.text = "After a session, you will be asked to rate and review your client. When rating and reviewing your client, please remember to be honest and leave an accurate review — as this will help other users increase QuickTutor’s overall trust and quality."
        
        quickCallsTitle.label.text = "QuickCalls"
        quickCallsBody.text = "Sometimes in urgent situations, it’s best to call someone directly as opposed to scheduling. Users have this ability if you as a tutor have activated QuickCalls. You can activate QuickCalls by entering your tutor settings, going to your preferences section, turning QuickCalls on with the custom toggle button and then setting your QuickCalls hourly rate. Be sure to tap the “save” button to save the changes you’ve made. Users will now be able to instantly call you by tapping the call icon on your profile and selecting a topic of their choice. We’ll send you a push notification when you receive QuickCalls!"
        
        quickCallRateTitle.label.text = "Setting your QuickCall hourly rate"
        quickCallRateBody.text = "QuickCall rates may vary drastically tutor-to-tutor, but the current rate is about 2-3x your regular hourly rate. Please remember, you are permitting all of your user connections (learners) to call you without your consent or notice."
    }

    override func applyConstraints() {
        super.applyConstraints()

        acceptSessionTitle.constrainSelf(top: header.snp.bottom)
        twoWaysSubtitle.constrainSelf(top: acceptSessionTitle.snp.bottom)
        twoWaysBody.constrainSelf(top: twoWaysSubtitle.snp.bottom)
        manualStartTitle.constrainSelf(top: twoWaysBody.snp.bottom)
        manualStartBody.constrainSelf(top: manualStartTitle.snp.bottom)
        automaticStartTitle.constrainSelf(top: manualStartBody.snp.bottom)
        automaticStartBody.constrainSelf(top: automaticStartTitle.snp.bottom)
        sessionStartTitle.constrainSelf(top: automaticStartBody.snp.bottom)
        sessionStartBody.constrainSelf(top: sessionStartTitle.snp.bottom)
        inSessionTitle.constrainSelf(top: sessionStartBody.snp.bottom)
        inSessionBody.constrainSelf(top: inSessionTitle.snp.bottom)
        reportSessionTitle.constrainSelf(top: inSessionBody.snp.bottom)
        reportSessionBody.constrainSelf(top: reportSessionTitle.snp.bottom)
        postSessionTitle.constrainSelf(top: reportSessionBody.snp.bottom)
        postSessionBody.constrainSelf(top: postSessionTitle.snp.bottom)
        quickCallsTitle.constrainSelf(top: postSessionBody.snp.bottom)
        quickCallsBody.constrainSelf(top: quickCallsTitle.snp.bottom)
        quickCallRateTitle.constrainSelf(top: quickCallsBody.snp.bottom)
        quickCallRateBody.constrainSelf(top: quickCallRateTitle.snp.bottom)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = TutorSessionsView()
    }

}
