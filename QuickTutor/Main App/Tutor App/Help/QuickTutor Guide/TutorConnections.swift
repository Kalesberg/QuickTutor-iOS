//
//  TutorConnections.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorConnectionsView: MainLayoutHeaderScroll {
    var connectingBody = SectionBody()
    var connectionRequestsTitle = SectionTitle()
    var connectionRequestsBody = SectionBody()
    var onceConnectedTitle = SectionTitle()
    var onceConnectedBody = SectionBody()

    override func configureView() {
        scrollView.addSubview(connectingBody)
        scrollView.addSubview(connectionRequestsTitle)
        scrollView.addSubview(connectionRequestsBody)
        scrollView.addSubview(onceConnectedTitle)
        scrollView.addSubview(onceConnectedBody)
        super.configureView()

        header.label.text = "Getting started"
        connectingBody.text = "After you become a QuickTutor, be sure to add as much information to your profile as possible in order to increase your chances of receiving connection requests.\n\nTo add information to your profile, you can tap on your \"tutor settings\" button from your dashboard (far left tab) or tap on your profile tab (far right button)."

        connectionRequestsTitle.label.text = "Connection requests"
        connectionRequestsBody.text = "Connection requests that have not yet been accepted should be at the top of your message threads in your messages tab.\n\nYou will not be able to message a user until you accept their connection request.\n\nTo accept a connection request, simply go to your messages with a user and tap the “accept” button below a connection request in the message thread."
        
        onceConnectedTitle.label.text = "Once connected"
        onceConnectedBody.text = "Once connected with a user, you can now communicate, coordinate sessions, calls and any other transactions. If your client needs help sending a session request or calling you, tell them to refer to the QuickTutor help menus in their user profile tab."
    }

    override func applyConstraints() {
        super.applyConstraints()

        connectingBody.constrainSelf(top: header.snp.bottom)
        connectionRequestsTitle.constrainSelf(top: connectingBody.snp.bottom)
        connectionRequestsBody.constrainSelf(top: connectionRequestsTitle.snp.bottom)
        onceConnectedTitle.constrainSelf(top: connectionRequestsBody.snp.bottom)
        onceConnectedBody.constrainSelf(top: onceConnectedTitle.snp.bottom)
    }
}

class TutorConnections: BaseViewController {
    override var contentView: TutorConnectionsView {
        return view as! TutorConnectionsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Connecting"
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = TutorConnectionsView()
    }

}
