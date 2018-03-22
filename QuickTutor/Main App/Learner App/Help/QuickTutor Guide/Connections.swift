//
//  Connections.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class ConnectionsView : MainLayoutHeaderScroll {
    
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
        
        title.label.text = "Connections"
        header.label.text = "Connecting"
        
        connectingBody.text = "The first step to connecting with a tutor is tapping the purple “Connect” button at the bottom of a tutor’s card or on their full profile. This will send a tutor a connection request.\n\nConnection requests are sent through the messaging system, which can be sent with manually typed messages or custom messages. You’ll be unable to message a tutor again until they accept your connection request.\n\nConnection requests that have not yet been accepted will appear in your “Tutors” tab. Once your connection request is accepted, you’ll be able to communicate freely."
        
        addingTutorsTitle.label.text = "Adding tutors by username"
        addingTutorsBody.text = "You can also add a tutor via username by tapping the “add” button located in the top right corner of the messaging system.\n\nTutors may market themselves through various avenues including but not limited to social media platforms, websites, and other means. A QuickTutor may send you their username on other platforms — you can add them this way. The same safety protocol still remains, make sure you inspect a tutor’s biography, photos, and social media before scheduling in-person sessions. "
        
        onceConnectedTitle.label.text = "Once connected"
        onceConnectedBody.text = "Once you are connected with a tutor, you can go to your “Tutors” tab in the messaging system. This is where you can see all your message threads with tutors, which display the tutor’s location or university, the past sessions you’ve had with them, their rating, and the last message sent between you two.\n\nTo message a tutor, simply tap on their message thread in the “Tutors” tab and your messages with them will open. Remember, until your connection request is accepted, you will not be able to message a tutor freely.\n\n"
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


class Connections : BaseViewController {
    
    override var contentView: ConnectionsView {
        return view as! ConnectionsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }
    
    override func loadView() {
        view = ConnectionsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        
    }
}
