//
//  Connections.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class ConnectionsView: MainLayoutHeaderScroll {
    var connectingBody = SectionBody()
    var addingTutorsTitle = SectionTitle()
    var addingTutorsBody = SectionBody()
    var onceConnectedTitle = SectionTitle()
    var onceConnectedBody = SectionBody()

    override func configureView() {
        scrollView.addSubview(connectingBody)
        scrollView.addSubview(addingTutorsTitle)
        scrollView.addSubview(addingTutorsBody)
        scrollView.addSubview(onceConnectedTitle)
        scrollView.addSubview(onceConnectedBody)
        super.configureView()

        header.label.text = "Connecting"

        connectingBody.text = "The first step to connecting with a tutor is tapping the purple \"Connect\" button at the bottom of a tutor’s card on their tutor card in search. Doing this will take you to your messenger where you can send a connection request to that tutor.\n\nConnection requests can be sent with manually typed messages or custom messages. You’ll be unable to message a tutor again until they accept your connection request.\n\nConnection requests that have not yet been accepted will appear in the \"sessions\" tab of your messenger. Once your connection request is accepted — you’ll be able to communicate freely, schedule sessions and send photos."

        addingTutorsTitle.label.text = "Adding tutors by username"
        addingTutorsBody.text = "You can add a tutor by username by tapping on your \"Connections\" icon in the top-right corner of your messenger. And then tap on the “Add Tutor” icon in the top-right corner of your connections list screen.\n\nTutors may market themselves through various venues, including but not limited to social media platforms, websites, and other means. A QuickTutor may send you their username on other platforms — you can add them this way. The same safety protocol remains — make sure you inspect a tutor’s biography, photos, and past sessions before scheduling an in-person tutoring session."

        onceConnectedTitle.label.text = "Once connected"
        onceConnectedBody.text = "Once you connect with a tutor, you can go to your \"messages\" tab to see all your messages with tutors you’ve connected with.\n\nTo message a tutor, tap on their message thread in the \"messages\" tab, and your messages with them will open. Remember —  until your connection request is accepted, you will NOT be able to message a tutor freely, send photos or schedule sessions. \n\n"
    }

    override func applyConstraints() {
        super.applyConstraints()

        connectingBody.constrainSelf(top: header.snp.bottom)
        addingTutorsTitle.constrainSelf(top: connectingBody.snp.bottom)
        addingTutorsBody.constrainSelf(top: addingTutorsTitle.snp.bottom)
        onceConnectedTitle.constrainSelf(top: addingTutorsBody.snp.bottom)
        onceConnectedBody.constrainSelf(top: onceConnectedTitle.snp.bottom)
    }
}

class Connections: BaseViewController {
    override var contentView: ConnectionsView {
        return view as! ConnectionsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Connections"
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = ConnectionsView()
    }

    override func handleNavigation() {}
}
