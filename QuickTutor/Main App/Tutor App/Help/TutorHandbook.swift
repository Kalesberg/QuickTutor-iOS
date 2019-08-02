//
//  TutorHandbook.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorHandookView: MainLayoutHeaderScroll {
    var setScheduleBody = SectionBody()
    var earnTitle = SectionTitle()
    var earnBody = SectionBody()
    var toolTitle = SectionTitle()
    var toolBody = SectionBody()
    var strings: [String] = []

    override func configureView() {
        scrollView.addSubview(setScheduleBody)
        scrollView.addSubview(earnTitle)
        scrollView.addSubview(earnBody)
        scrollView.addSubview(toolTitle)
        scrollView.addSubview(toolBody)
        super.configureView()

        header.label.text = "Set your own schedule"

        setScheduleBody.text = "Tutor whenever you want — day or night, 365 days per year. When you tutor is always up to you so that it won't interfere with the most important things in life. Sessions can be scheduled as early as fifteen minutes in the future or up to thirty days in advance. "

        earnTitle.label.text = "Earn what you want"

        earnBody.text = "Earn whatever you'd like, however you'd like and teach for up to $15,000 for a single session! As a QuickTutor, you decide how valuable your time is."

        toolTitle.label.text = "The ultimate experience"

        toolBody.text = "Tap and tutor. All you have to do is build up your profile and wait. Users will come to you for learning!"
    }

    override func applyConstraints() {
        super.applyConstraints()

        setScheduleBody.constrainSelf(top: header.snp.bottom)
        earnTitle.constrainSelf(top: setScheduleBody.snp.bottom)
        earnBody.constrainSelf(top: earnTitle.snp.bottom)
        toolTitle.constrainSelf(top: earnBody.snp.bottom)
        toolBody.constrainSelf(top: toolTitle.snp.bottom)
    }
}

class TutorHandook: BaseViewController {
    override var contentView: TutorHandookView {
        return view as! TutorHandookView
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
        view = TutorHandookView()
    }

    override func handleNavigation() {}
}
