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
    
    override func configureView() {
        scrollView.addSubview(searchBody)
        scrollView.addSubview(pickingTutorTitle)
        scrollView.addSubview(pickingTutorBody)
        
        super.configureView()

        header.label.text = "Searching"
        searchBody.text = "There are various ways to search on QuickTutor.You can search by tapping on the search bar located in your home tab, then selecting \"All\", \"Topics\" or \"People\".\n\nWhen searching \"All\" — search by entering any topic you would like to learn or the name/username of anyone you would like to learn from.\n\nWhen searching \"people\" you can enter in a tutor’s name or username to find their profile and connect with them."

        pickingTutorTitle.label.text = "There are two other ways to search on QuickTutor:"
        pickingTutorBody.text = "1. In your sessions tab (center, flame icon), tap the violet “start learning” button.\n\n2.In your saved tab (heart icon) tap the violet “find tutors” button.\n\nIf we don’t have what you’re looking for whether it be a topic or a tutor that teaches a topic — we’ll let you know. If we don’t have a topic you’re looking for, you can always submit a topic to the QuickTutor queue. We’ll review your submission and get back to you within 72 hours!"
    }

    override func applyConstraints() {
        super.applyConstraints()

        searchBody.constrainSelf(top: header.snp.bottom)
        pickingTutorTitle.constrainSelf(top: searchBody.snp.bottom, true)
        pickingTutorBody.constrainSelf(top: pickingTutorTitle.snp.bottom, 10)
    }
}

class SearchTutorVC: BaseViewController {
    override var contentView: SearchTutorView {
        return view as! SearchTutorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Searching"
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
