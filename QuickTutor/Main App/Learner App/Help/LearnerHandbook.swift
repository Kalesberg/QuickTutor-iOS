//
//  LearnerHandbook.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class LearnerHandookView: MainLayoutHeaderScroll {
    var learningEasyBody = SectionBody()
    var subjectsSubtitle = SectionSubTitle()
    var subjectsBody = SectionBody()
    var strings: [String] = []

    override func configureView() {
        scrollView.addSubview(learningEasyBody)
        scrollView.addSubview(subjectsSubtitle)
        scrollView.addSubview(subjectsBody)
        super.configureView()

        header.label.text = "Learning made easy"

        learningEasyBody.text = "Learn anything, from anyone, anywhere, at any time. Connect to anyone in your area or someone from the other side of the world and learn from each other. You can learn in-person or through instant video calling. You can schedule a session as soon as 15 minutes in advance or late as 30 days in advance."

        subjectsSubtitle.label.text = "Infinite possibilities"
        subjectsBody.text = "QuickTutor has infinite topics to learn and teach. We offer learning in any academic subject, skill, hobby, language, or talent you can think of! We also have a submit queue in which anyone can submit any topic they feel should be available to learn or teach!"
    }

    override func applyConstraints() {
        super.applyConstraints()

        learningEasyBody.constrainSelf(top: header.snp.bottom)
        subjectsSubtitle.constrainSelf(top: learningEasyBody.snp.bottom)
        subjectsBody.constrainSelf(top: subjectsSubtitle.snp.bottom)
    }
}

class LearnerHandookVC: BaseViewController {
    override var contentView: LearnerHandookView {
        return view as! LearnerHandookView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Handbook"
        contentView.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = LearnerHandookView()
    }

    override func handleNavigation() {}
}
