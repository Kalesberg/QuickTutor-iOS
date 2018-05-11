//
//  TutorHandbook.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorHandookView : MainLayoutHeaderScroll {
    
    var setScheduleBody = SectionBody()
    var earnTitle = SectionTitle()
    var earnBody = SectionBody()
    var toolTitle = SectionTitle()
    var toolBody = SectionBody()
    var easyProfileTitle = SectionTitle()
    var easyProfileBody = SectionBody()
    var safetyTitle = SectionTitle()
    var safetyBody = SectionBody()
    var reviewTitle = SectionTitle()
    var reviewBody = SectionBody()
    var meetTitle = SectionTitle()
    var meetBody = SectionBody()
    var privateInfoTitle = SectionTitle()
    var privateInfoBody = SectionBody()
    var strings: [String] = []
    
    override func configureView() {
        scrollView.addSubview(setScheduleBody)
        scrollView.addSubview(earnTitle)
        scrollView.addSubview(earnBody)
        scrollView.addSubview(toolTitle)
        scrollView.addSubview(toolBody)
        scrollView.addSubview(easyProfileTitle)
        scrollView.addSubview(easyProfileBody)
        scrollView.addSubview(safetyTitle)
        scrollView.addSubview(safetyBody)
        scrollView.addSubview(reviewTitle)
        scrollView.addSubview(reviewBody)
        scrollView.addSubview(meetTitle)
        scrollView.addSubview(meetBody)
        scrollView.addSubview(privateInfoTitle)
        scrollView.addSubview(privateInfoBody)
        super.configureView()
        
        title.label.text = "Tutor Handbook"
        header.label.text = "Set your own schedule"
        
        setScheduleBody.text = "You can tutor whenever you want – day or night, 365 days a year. When you tutor is always up to you, so it won’t interfere with the most important things in life. Sessions can be scheduled as early as fifteen minutes in the future or up to thirty days in advance. "
        
        earnTitle.label.text = "Earn what you want"
        
        earnBody.text = "With QuickTutor, you can charge whatever you’d like. For your first fifteen hours of tutoring, a 10% service fee will be subtracted from your fare. After fifteen hours of tutoring, the fee becomes only 7.5%. The fee helps us maintain the QuickTutor platform and make continuous investments to improve our technologies."
        
        toolTitle.label.text = "The ultimate biz management tool"
        
        toolBody.text = "Tap and tutor. All you have to do is build up your profile and wait -- learners will send you connection requests, you message them, coordinate session details and then accept their requests for tutoring sessions. You can also send photos back and forth in case they have a quick question. "
        
        easyProfileTitle.label.text = "Easy profile setup:"
        
        strings = ["1.  Profile Pictures\n      Upload one-to-four pictures of yourself. Note: all user profile pictures are subject to moderation.\n\n", "2.  Biography\n      Make sure your bio clearly describes you, your experience/expertise, lists any certifications you may have, and what you are looking for in a learner.\n\n", "3.  Courses Completed\n      If you’re currently a university student or have been, you can use our courses completed feature to insert the class codes of specific classes you’ve completed.\n\n", "4.  Social Connect\n      QuickTutor enables you to connect your Instagram account so that learners can see your Instagram pictures. To connect your Instagram, just scroll to the bottom of your profile and press “connect Instagram”."]
        
        let attributesDictionary = [NSAttributedStringKey.font : earnBody.font]
        let fullAttributedString = NSMutableAttributedString(string: "", attributes: attributesDictionary)
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        easyProfileBody.attributedText = fullAttributedString
        
        safetyTitle.label.text = "Safety tips"
        
        safetyBody.text = "Understand that anyone who is able to commit identity theft or steal an SSN can also falsify a profile, so we suggest you take the following steps for your own protection."
        
        reviewTitle.label.text = "Review tutor feedback"
        
        reviewBody.text = "Look at the tutor reviews section of a learner’s profile by tapping the “See All” button to the right of their rating and reviews (1 to 5 stars). "
        
        meetTitle.label.text = "Meet in public (for in-person tutoring)"
        
        meetBody.text = "If you choose to have an in-person session with a learner, always tell a friend, family member, or classmate where you are going and when you will be back. Always provide your own transportation to and from your lesson and meet in a public place with people around such as a coffee shop, library, or fast-food restaurant. "
        
        privateInfoTitle.label.text = "Never disclose private information"
        
        privateInfoBody.text = "Never disclose private information like your last name, e-mail address, home address, phone number, or other information in your biography or through the messaging system. Immediately stop communicating with and report any tutor who pressures you for private or financial information, or attempts in any way to manipulate you into revealing private information.\n\n"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        setScheduleBody.constrainSelf(top: header.snp.bottom)
        earnTitle.constrainSelf(top: setScheduleBody.snp.bottom)
        earnBody.constrainSelf(top: earnTitle.snp.bottom)
        toolTitle.constrainSelf(top: earnBody.snp.bottom)
        toolBody.constrainSelf(top: toolTitle.snp.bottom)
        easyProfileTitle.constrainSelf(top: toolBody.snp.bottom)
        easyProfileBody.constrainSelf(top: easyProfileTitle.snp.bottom)
        safetyTitle.constrainSelf(top: easyProfileBody.snp.bottom)
        safetyBody.constrainSelf(top: safetyTitle.snp.bottom)
        reviewTitle.constrainSelf(top: safetyBody.snp.bottom)
        reviewBody.constrainSelf(top: reviewTitle.snp.bottom)
        meetTitle.constrainSelf(top: reviewBody.snp.bottom)
        meetBody.constrainSelf(top: meetTitle.snp.bottom)
        privateInfoTitle.constrainSelf(top: meetBody.snp.bottom)
        privateInfoBody.constrainSelf(top: privateInfoTitle.snp.bottom)
    }
}


class TutorHandook : BaseViewController {
    
    override var contentView: TutorHandookView {
        return view as! TutorHandookView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }
    
    override func loadView() {
        view = TutorHandookView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        
    }
}
