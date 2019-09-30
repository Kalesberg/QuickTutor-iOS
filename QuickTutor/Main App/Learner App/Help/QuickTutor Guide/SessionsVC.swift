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
    var requestingSessionBody       = SectionBody()
    var startingSessionTitle        = SectionTitle()
    var startingSessionBody         = SectionBody()
    var manualSessionTitle          = SectionTitle()
    var manualSessionBody           = SectionBody()
    var automaticSessionTitle       = SectionTitle()
    var automaticSessionBody        = SectionBody()
    var startingSessionTitle2       = SectionTitle()
    var startingSessionBody2        = SectionBody()
    var inSessionTitle              = SectionTitle()
    var inSessionBody               = SectionBody()
    var guidelinesTitle             = SectionTitle()
    var guidelinesBody              = SectionBody()
    var reportOnPastSessionTitle    = SectionSubTitle()
    var reportOnPastSessionBody     = SectionBody()
    var reportOnTermsBody           = SectionBody()
    var postSessionTitle            = SectionTitle()
    var postSessionBody             = SectionBody()
    var quickCallsTitle             = SectionTitle()
    var quickCallsBody              = SectionBody()

    var communityGuidelinesRange: NSRange?
    var termsOfUseRange: NSRange?
    
    override func configureView() {
        scrollView.addSubview(requestingSessionBody)
        scrollView.addSubview(startingSessionTitle)
        scrollView.addSubview(startingSessionBody)
        scrollView.addSubview(manualSessionTitle)
        scrollView.addSubview(manualSessionBody)
        scrollView.addSubview(automaticSessionTitle)
        scrollView.addSubview(automaticSessionBody)
        scrollView.addSubview(startingSessionTitle2)
        scrollView.addSubview(startingSessionBody2)
        scrollView.addSubview(inSessionTitle)
        scrollView.addSubview(inSessionBody)
        scrollView.addSubview(guidelinesTitle)
        scrollView.addSubview(guidelinesBody)
        scrollView.addSubview(reportOnPastSessionTitle)
        scrollView.addSubview(reportOnPastSessionBody)
        scrollView.addSubview(reportOnTermsBody)
        scrollView.addSubview(postSessionTitle)
        scrollView.addSubview(postSessionBody)
        scrollView.addSubview(quickCallsTitle)
        scrollView.addSubview(quickCallsBody)
        super.configureView()

        header.label.text = "Chatting & Requesting Sessions"
        var attributesDictionary: [NSAttributedString.Key: Any] = [.font: requestingSessionBody.font]
        var fullAttributedText = NSMutableAttributedString(string: "Once you’re connected with a tutor, you can message them, as well as send 30+ different forms of documents/files, photos, and videos.\n\nYour ", attributes: attributesDictionary)
        fullAttributedText.append(NSAttributedString(string: "connect", attributes: [.font: UIFont.qtBoldItalicFont(size: 14)]))
        fullAttributedText.append(NSAttributedString(string: " button will turn into a ", attributes: attributesDictionary))
        fullAttributedText.append(NSAttributedString(string: "request session", attributes: [.font: UIFont.qtBoldItalicFont(size: 14)]))
        fullAttributedText.append(NSAttributedString(string: " button and you’ll now have the capability to schedule in-person and online learning sessions by tapping the “request session” button on their profile footer.\n\nYou can also request a session by tapping on the big, violet block button located in your sessions tab that says \"request session\" (center, flame icon) and then filling out all of the required information.", attributes: attributesDictionary))
        requestingSessionBody.attributedText = fullAttributedText
        
        startingSessionTitle.label.text = "Starting Sessions"
        startingSessionBody.text = "After you send a session request, you have to wait for your tutor to accept the request. Once accepted, you can start sessions by tapping on the “Start Session” button in your message threads or on the specific scheduled session in your sessions tab and then tapping the start button (checkmark icon)."
        manualSessionTitle.label.text = "Manually starting sessions"
        manualSessionBody.text = "Sometimes you and a tutor may agree to start your session before the scheduled start time. You or your tutor can manually start sessions by going to the \"Sessions tab\", tapping on the specific session in the \"Upcoming\" section, and then tapping the start button (checkmark icon)."
        automaticSessionTitle.label.text = "Automatically starting sessions"
        automaticSessionBody.text = "When it is time for a session to begin, it will simply begin. If you are outside of the application, it will send you a push notification, which when tapped on, will take you directly into the session. If your tutor is not entering the session, you’ll have to wait on the start menu until they tap the push notification outside of their app or open the QuickTutor app."
        startingSessionTitle2.label.text = "Starting sessions"
        startingSessionBody2.text = "Whether your session is started manually or automatically — if you are outside of the app, you’ll receive a push notification that it is time to begin. If you are inside the app when your session is manually or automatically started, you will be taken directly to the session starting menu."
        inSessionTitle.label.text = "In-Session"
        inSessionBody.text = "In-person and online sessions operate similarly. Both users can pause or leave sessions at anytime. When a session is paused — the clock is completely stopped, users are not charged and tutors will not be compensated for this time. You can pause a session by tapping on the arrow button in the bottom left corner of your screen and then selecting \"pause session\".\n\nWhen a session’s time is up, we will ask you you’d like to keep the session going or end it immediately. Your tutor can choose to end the session immediately and override your choice at any time.\n\nIf you decide to add time, your tutor has the option to accept or deny the added time request. If they deny the time addition, the session will end immediately."
        guidelinesTitle.label.text = "Community guidelines & reports"
        guidelinesBody.text = "You will not be penalized for leaving sessions early. Tutors are topic to disciplinary action if leaving sessions early becomes a trend.\n\nYou can report a tutor for canceling, being late to a session, or not showing up to a session in your \"Past Transactions\" section on your profile tab."
        reportOnPastSessionTitle.label.text = "To file a report on a past session:"
        
        attributesDictionary = [.font: reportOnPastSessionBody.font]
        fullAttributedText = NSMutableAttributedString(string: "", attributes: attributesDictionary)
        let strings = ["1.  Tap the profile tab (profile icon) in the bottom right corner of your screen.\n",
                       "2.  Select the \"past transactions\" from your profile tab option menu.\n",
                       "3.  Tap the violet flag icon.\n",
                       "4.  Fill out a report accurately to the best of your ability.\n\n"]
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedText.append(attributedString)
        }
        fullAttributedText.append(NSAttributedString(string: "We will respond to your report within 72 hours.\n", attributes: attributesDictionary))
        reportOnPastSessionBody.attributedText = fullAttributedText
        
        attributesDictionary = [.font: reportOnTermsBody.font]
        fullAttributedText = NSMutableAttributedString(string: "Visit our ", attributes: attributesDictionary)
        
        let guidelinesString = NSAttributedString(string: "Community Guidelines", attributes: [.font: UIFont.qtBoldFont(size: 14), .foregroundColor: UIColor.qtVioletColor])
        fullAttributedText.append(guidelinesString)
        communityGuidelinesRange = (fullAttributedText.string as NSString).range(of: guidelinesString.string)
        
        fullAttributedText.append(NSAttributedString(string: " or ", attributes: attributesDictionary))
        let termsOfUseString = NSAttributedString(string: "Service Terms of Use", attributes: [.font: UIFont.qtBoldFont(size: 14), .foregroundColor: UIColor.qtVioletColor])
        fullAttributedText.append(termsOfUseString)
        termsOfUseRange = (fullAttributedText.string as NSString).range(of: termsOfUseString.string)
        
        fullAttributedText.append(NSAttributedString(string: " to learn more about our rules, regulations and reportable in-app offenses.", attributes: attributesDictionary))
        reportOnTermsBody.attributedText = fullAttributedText
        
        postSessionTitle.label.text = "Post-session"
        postSessionBody.text = "After a session, you will be asked to rate and review your tutor. Please remember to be honest and leave an accurate review — as this will help other users, help your tutor, and increase QuickTutor’s overall trust and quality."
        quickCallsTitle.label.text = "QuickCalls"
        quickCallsBody.text = "Sometimes in urgent situations, it’s best to call someone directly as opposed to scheduling. You can instantly call a tutor by tapping the call button (phone icon) on their profile footer, next to the request session button."
    }

    override func applyConstraints() {
        super.applyConstraints()

        requestingSessionBody.constrainSelf(top: header.snp.bottom)
        startingSessionTitle.constrainSelf(top: requestingSessionBody.snp.bottom)
        startingSessionBody.constrainSelf(top: startingSessionTitle.snp.bottom)
        manualSessionTitle.constrainSelf(top: startingSessionBody.snp.bottom)
        manualSessionBody.constrainSelf(top: manualSessionTitle.snp.bottom)
        automaticSessionTitle.constrainSelf(top: manualSessionBody.snp.bottom)
        automaticSessionBody.constrainSelf(top: automaticSessionTitle.snp.bottom)
        startingSessionTitle2.constrainSelf(top: automaticSessionBody.snp.bottom)
        startingSessionBody2.constrainSelf(top: startingSessionTitle2.snp.bottom)
        inSessionTitle.constrainSelf(top: startingSessionBody2.snp.bottom)
        inSessionBody.constrainSelf(top: inSessionTitle.snp.bottom)
        guidelinesTitle.constrainSelf(top: inSessionBody.snp.bottom)
        guidelinesBody.constrainSelf(top: guidelinesTitle.snp.bottom)
        reportOnPastSessionTitle.constrainSelf(top: guidelinesBody.snp.bottom)
        reportOnPastSessionBody.constrainSelf(top: reportOnPastSessionTitle.snp.bottom)
        reportOnTermsBody.constrainSelf(top: reportOnPastSessionBody.snp.bottom)
        postSessionTitle.constrainSelf(top: reportOnTermsBody.snp.bottom)
        postSessionBody.constrainSelf(top: postSessionTitle.snp.bottom)
        quickCallsTitle.constrainSelf(top: postSessionBody.snp.bottom)
        quickCallsBody.constrainSelf(top: quickCallsTitle.snp.bottom)
    }
}

class SessionsVC: BaseViewController {
    override var contentView: SessionsView {
        return view as! SessionsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Learning"
        contentView.layoutIfNeeded()
        
        contentView.reportOnTermsBody.isUserInteractionEnabled = true
        contentView.reportOnTermsBody.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = SessionsView()
    }

    override func handleNavigation() {}
    
    @objc
    func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let communityGuidelinesRange = contentView.communityGuidelinesRange,
            let termsOfUseRange = contentView.termsOfUseRange else { return }
        
        if gesture.didTapAttributedTextInLabel(label: contentView.reportOnTermsBody, inRange: communityGuidelinesRange) {
            showCommunityGuidelines()
        }
        
        if gesture.didTapAttributedTextInLabel(label: contentView.reportOnTermsBody, inRange: termsOfUseRange) {
            showTermsOfUse()
        }
    }
}
