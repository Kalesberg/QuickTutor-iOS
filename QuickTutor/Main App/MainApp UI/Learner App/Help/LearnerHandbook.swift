//
//  LearnerHandbook.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class LearnerHandookView : MainLayoutHeaderScroll {
    
    var learningEasyBody = SectionBody()
    var subjectsSubtitle = SectionSubTitle()
    var subjectsBody = SectionBody()
    var easyProfileSubtitle = SectionSubTitle()
    var easyProfileBody = SectionBody()
    var safetyTipsTitle = SectionSubTitle()
    var safetyTipsBody  = SectionBody()
    var conversationSubtitle = SectionSubTitle()
    var conversationBody = SectionBody()
    var paymentsSubtitle = SectionSubTitle()
    var paymentsBody = SectionBody()
    var tooGoodSubtitle = SectionSubTitle()
    var tooGoodBody = SectionBody()
    var reviewSubtitle = SectionSubTitle()
    var reviewBody = SectionBody()
    var meetUpSubtitle = SectionSubTitle()
    var meetUpBody = SectionBody()
    var adultsSubtitle = SectionSubTitle()
    var adultsBody = SectionBody()
    var privateInfoSubtitle = SectionSubTitle()
    var privateInfoBody = SectionBody()
    var strings: [String] = []
    
    override func configureView() {
        scrollView.addSubview(learningEasyBody)
        scrollView.addSubview(subjectsSubtitle)
        scrollView.addSubview(subjectsBody)
        scrollView.addSubview(easyProfileSubtitle)
        scrollView.addSubview(easyProfileBody)
        scrollView.addSubview(safetyTipsTitle)
        scrollView.addSubview(safetyTipsBody)
        scrollView.addSubview(conversationSubtitle)
        scrollView.addSubview(conversationBody)
        scrollView.addSubview(paymentsSubtitle)
        scrollView.addSubview(paymentsBody)
        scrollView.addSubview(tooGoodSubtitle)
        scrollView.addSubview(tooGoodBody)
        scrollView.addSubview(reviewSubtitle)
        scrollView.addSubview(reviewBody)
        scrollView.addSubview(meetUpSubtitle)
        scrollView.addSubview(meetUpBody)
        scrollView.addSubview(adultsSubtitle)
        scrollView.addSubview(adultsBody)
        scrollView.addSubview(privateInfoSubtitle)
        scrollView.addSubview(privateInfoBody)
        super.configureView()
        
        title.label.text = "Learner Handbook"
        header.label.text = "Learning made easy"
        
        learningEasyBody.text = "Learn anything, from anyone, anywhere, at any time. Connect to anyone in your area or all over the world, negotiate a price, and begin learning. You can learn in person or through instant video calling. You can schedule a session as soon as 15 minutes in advance or late as 30 days in advance."
        
        subjectsSubtitle.label.text = "Thousands of Subjects"
        subjectsBody.text = "QuickTutor has twelve categories, and six subcategories per category. We offer tutoring in any academic subject, skill, hobby, language, or talent you can think of! From auto and health to tech and remedial education – we have over 9,000 subjects. We also have a submit queue in which anyone can submit a subject they believe should be available to learn or teach!"
        
        easyProfileSubtitle.label.text = "Easy profile setup"
        
        strings = ["•  Profile Pictures\n      Upload one-to-four pictures of yourself. Note: all user profile pictures are subject to moderation.\n\n", "•  Biography\n      Make sure your bio clearly describes you, what you need, and what you are looking for in a tutor."]
        
		let attributesDictionary : [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : easyProfileBody.font]
        let fullAttributedString = NSMutableAttributedString(string: "", attributes: attributesDictionary)
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        easyProfileBody.attributedText = fullAttributedString
        
        safetyTipsTitle.label.text = "Safety Tips"
        safetyTipsBody.text = "Understand that anyone who is able to commit identity theft or steal an SSN can also falsify a profile, so we suggest you take the following steps for your own protection."
        
        conversationSubtitle.label.text = "KEEP CONVERSATIONS IN THE MESSAGING SYSTEM:"
        conversationBody.text = "QuickTutor® invented its unique connection and messaging system to provide all users with security and choice. On QuickTutor®, a Learner has to send a connection request to a Tutor, and then that Tutor has to accept the connection request in order for the users to message each other and set-up tutoring sessions. This is so Tutors have the choice of who they would like to work with, and session information can be shared privately, if desired. The QuickTutor® messaging system allows you to communicate and set-up tutoring sessions, without having to give away any personal or private information like your phone number or email. Keeping your conversations in the messaging system is a safer way to protect yourself."
        
        paymentsSubtitle.label.text = "KEEP PAYMENTS SECURE THROUGH QUICKTUTOR®:"
        paymentsBody.text = "Never facilitate transactions outside of the QuickTutor® application. Not only is this inconvenient for both tutors and learners, this is detrimental to the QuickTutor® community. A session must occur through the app in order for tutors to build a rating and have reviews, which will bring them more customers. It is also in violation of the SERVICE TERMS OF USE and PAYMENTS TERMS OF SERVICE if a Tutor collects or requests payment directly from the Learners by cash, check, or otherwise, for tutoring or anything else. In order to maintain all user’s safety and ensure Tutor payment and security, keep payments through the app."
        
        tooGoodSubtitle.label.text = "TOO GOOD TO BE TRUE? FIND ANOTHER TUTOR:"
        tooGoodBody.text = "We’ve all had that gut feeling. Sometimes an in-person tutoring session might just seem too good to be true. We’ll leave it up to you! Make sure your comfortable going to every in-person session you attend."
        
        reviewSubtitle.label.text = "REVIEW LEARNER FEEDBACK:"
        reviewBody.text = "Look at the Learner reviews section of a Tutor’s profile by tapping the “See All” button to the right of their rating and reviews (1 to 5 stars)."
        
        meetUpSubtitle.label.text = "MEET IN PUBLIC (FOR IN-PERSON TUTORING):"
        meetUpBody.text = "If you choose to have an in-person session with a Tutor, always tell a friend, family member, or classmate where you are going and when you will be back. Always provide your own transportation to and from your session and meet in a public place with people around such as a library or coffee shop."
        
        adultsSubtitle.label.text = "ADULTS, ATTEND SESSIONS WITH YOUR MINOR LEARNERS:"
        adultsBody.text = "QuickTutor® may eventually have parent/guardian and minor accounts, but for now an adult should always be present for tutoring sessions if a learner is under the age of eighteen."
        
        privateInfoSubtitle.label.text = "NEVER DISCLOSE PRIVATE INFORMATION"
        privateInfoBody.text = "Never disclose private information like your last name, e-mail address, home address, phone number, or other information in your biography or through the messaging system. Immediately stop communicating with and report any Tutor or Learner who pressures you for private or financial information or attempts in any way to manipulate you into revealing private information."
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        learningEasyBody.constrainSelf(top: header.snp.bottom)
        subjectsSubtitle.constrainSelf(top: learningEasyBody.snp.bottom)
        subjectsBody.constrainSelf(top: subjectsSubtitle.snp.bottom)
        easyProfileSubtitle.constrainSelf(top: subjectsBody.snp.bottom)
        easyProfileBody.constrainSelf(top: easyProfileSubtitle.snp.bottom)
        safetyTipsTitle.constrainSelf(top: easyProfileBody.snp.bottom)
        safetyTipsBody.constrainSelf(top: safetyTipsTitle.snp.bottom)
        conversationSubtitle.constrainSelf(top: safetyTipsBody.snp.bottom)
        conversationBody.constrainSelf(top: conversationSubtitle.snp.bottom)
        paymentsSubtitle.constrainSelf(top: conversationBody.snp.bottom)
        paymentsBody.constrainSelf(top: paymentsSubtitle.snp.bottom)
        tooGoodSubtitle.constrainSelf(top: paymentsBody.snp.bottom)
        tooGoodBody.constrainSelf(top: tooGoodSubtitle.snp.bottom)
        reviewSubtitle.constrainSelf(top: tooGoodBody.snp.bottom)
        reviewBody.constrainSelf(top: reviewSubtitle.snp.bottom)
        meetUpSubtitle.constrainSelf(top: reviewBody.snp.bottom)
        meetUpBody.constrainSelf(top: meetUpSubtitle.snp.bottom)
        adultsSubtitle.constrainSelf(top: meetUpBody.snp.bottom)
        adultsBody.constrainSelf(top: adultsSubtitle.snp.bottom)
        privateInfoSubtitle.constrainSelf(top: adultsBody.snp.bottom)
        privateInfoBody.constrainSelf(top: privateInfoSubtitle.snp.bottom)
    }
}


class LearnerHandook : BaseViewController {
    
    override var contentView: LearnerHandookView {
        return view as! LearnerHandookView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }
    
    override func loadView() {
        view = LearnerHandookView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        
    }
}
