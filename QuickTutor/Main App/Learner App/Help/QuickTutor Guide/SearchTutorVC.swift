//
//  SearchTutor.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class SearchTutorView: MainLayoutHeaderScroll {
    var searchBody = SectionBody()
    var pickingTutorTitle = SectionTitle()
    var pickingTutorBody = SectionBody()
    var tutorBioSubtitle = SectionSubTitle()
    var tutorBioBody = SectionBody()
    var tutorAvailSubtitle = SectionSubTitle()
    var tutorAvailBody = SectionBody()
    var tutorPolicySubtitle = SectionSubTitle()
    var tutorPolicyBody = SectionBody()
    var examineProfileTitle = SectionSubTitle()
    var examineProfileBody = SectionBody()

    override func configureView() {
        scrollView.addSubview(searchBody)
        scrollView.addSubview(pickingTutorTitle)
        scrollView.addSubview(pickingTutorBody)
        scrollView.addSubview(tutorBioSubtitle)
        scrollView.addSubview(tutorBioBody)
        scrollView.addSubview(tutorAvailSubtitle)
        scrollView.addSubview(tutorAvailBody)
        scrollView.addSubview(tutorPolicySubtitle)
        scrollView.addSubview(tutorPolicyBody)
        scrollView.addSubview(examineProfileTitle)
        scrollView.addSubview(examineProfileBody)
        super.configureView()

        header.label.text = "Searching"

        searchBody.text = "You can search for tutors by tapping on the search bar (top, center) on the home page and then either typing in a subject you'd like to learn or tapping on one of the six subcategories associated within each category.\n\nYou can do a quick search by tapping on one of our twelve categories on the home page, which will then filter all tutors who teach subjects in that category."

        pickingTutorTitle.label.text = "Picking the right tutor"
        pickingTutorBody.text = "Selecting a tutor can sometimes be a difficult decision. Our search algorithm is built to ensure you are connected with the highest rated and most experienced tutors.\n\nHere are some tips to ensure you have the best experience possible: "

        tutorBioSubtitle.label.text = "1.  Thoroughly read a tutor's biography"
        tutorBioBody.text = "Tutors are asked to describe their expertise, knowledge, and abilities in their biography. As well as if they have received any awards or certifications in their particular field. Tutors also list what they are seeking in a learner, so make sure to take your learning style to note when reading a tutor's biography."

        tutorAvailSubtitle.label.text = "2.  Check a tutor's availability"
        tutorAvailBody.text = "Ensuring that a tutor is available on the day or days, you need tutoring is extremely important for your selection. Most tutors are busy with several learners, so make sure to check a tutor's availability and communicate frequently."

        tutorPolicySubtitle.label.text = "3.  Be aware of a tutor's policies and preferences"
        tutorPolicyBody.text = "Tutors can set tutoring policies and list their preferences for price, traveling and online tutoring. A tutor's cancellation policy and late policy could cause a dispute that will charge your payment method if you violate their policies. Be aware of a tutor's policies, so you don't break them, and make sure a tutor's preferences fit your expectations."

        examineProfileTitle.label.text = "4.  Examine profile pictures and social media"
        examineProfileBody.text = "QuickTutor enables all users to upload up to four profile pictures. Please examine a tutor's photographs and make the best decision you can when choosing whether or not to have an in-person tutoring session.\n\n"
    }

    override func applyConstraints() {
        super.applyConstraints()

        searchBody.constrainSelf(top: header.snp.bottom)
        pickingTutorTitle.constrainSelf(top: searchBody.snp.bottom)
        pickingTutorBody.constrainSelf(top: pickingTutorTitle.snp.bottom)
        tutorBioSubtitle.constrainSelf(top: pickingTutorBody.snp.bottom)
        tutorBioBody.constrainSelf(top: tutorBioSubtitle.snp.bottom)
        tutorAvailSubtitle.constrainSelf(top: tutorBioBody.snp.bottom)
        tutorAvailBody.constrainSelf(top: tutorAvailSubtitle.snp.bottom)
        tutorPolicySubtitle.constrainSelf(top: tutorAvailBody.snp.bottom)
        tutorPolicyBody.constrainSelf(top: tutorPolicySubtitle.snp.bottom)
        examineProfileTitle.constrainSelf(top: tutorPolicyBody.snp.bottom)
        examineProfileBody.constrainSelf(top: examineProfileTitle.snp.bottom)
    }
}

class SearchTutorVC: BaseViewController {
    override var contentView: SearchTutorView {
        return view as! SearchTutorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Searching for a tutor"
        contentView.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = SearchTutorView()
    }

    override func handleNavigation() {}
}
