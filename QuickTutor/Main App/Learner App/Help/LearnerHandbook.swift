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
    var safetyTipsTitle = SectionTitle()
    var safetyTipsBody  = SectionBody()
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
        
        learningEasyBody.text = "Learn anything, from anyone, anywhere, at anytime. Connect to anyone in your area or all over the world, negotiate a price, and begin learning. You can learn in person or through instant video calling, you can set up a session now or schedule for later."
        
        subjectsSubtitle.label.text = "Thousands of Subjects"
        subjectsBody.text = "QuickTutor has twelve categories, and six subcategories per category. We offer tutoring in any academic subject, skill, hobby, language, or talent you can think of! From auto and health, to tech and remedial education – we have over 20,000 subjects."
        
        easyProfileSubtitle.label.text = "Easy profile setup"
        
        strings = ["1.  Profile Pictures\n      Upload one-to-four pictures of yourself. Note: all user profile pictures are subject to moderation.\n\n", "2.  Biography\n      Make sure your bio clearly describes you, what you need, and what you are looking for in a tutor.\n\n", "3.  Class Schedule\n      If you’re a university student, you can use our class schedule feature to insert the class codes of your specific university’s classes you’re currently enrolled in.\n\n", "4.  Social Connect\n      QuickTutor enables you to connect your Instagram account so that tutors can see your Instagram pictures. To connect your Instagram, just scroll to the bottom of your profile and press “connect Instagram”."]
        
        let attributesDictionary = [NSAttributedStringKey.font : easyProfileBody.font]
        let fullAttributedString = NSMutableAttributedString(string: "", attributes: attributesDictionary)
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        easyProfileBody.attributedText = fullAttributedString
        
        safetyTipsTitle.label.text = "Safety Tips"
        safetyTipsBody.text = "Understand that anyone who is able to commit identity theft or steal an SSN can also falsify a profile, so we suggest you take the following steps for your own protection."
        
        reviewSubtitle.label.text = "Review learner feedback"
        reviewBody.text = "Look at the learner reviews section of a tutor’s profile by tapping the “See All” button to the right of their rating and reviews (1 to 5 stars)."
        
        meetUpSubtitle.label.text = "Meet in person (for in-person tutoring)"
        meetUpBody.text = "If you choose to have an in-person session with a tutor, always tell a friend, family member, or classmate where you are going and when you will be back. Always provide your own transportation to and from your lesson and meet in a public place with people around such as a library or coffee shop."
        
        adultsSubtitle.label.text = "Adults, attend sessions with your learners"
        adultsBody.text = "QuickTutor will eventually have parent/guardian and minor accounts, but for now an adult should always be present for tutoring sessions if a learner is under the age of eighteen."
        
        privateInfoSubtitle.label.text = "Never disclose private information"
        privateInfoBody.text = "Never disclose private information like your last name, Email address, home address, phone number, or other information in your biography or through the messaging system. Immediately stop communicating with and report any tutor who pressures you for private or financial information, or attempts in any way to manipulate you into revealing private information."
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
        reviewSubtitle.constrainSelf(top: safetyTipsBody.snp.bottom)
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
