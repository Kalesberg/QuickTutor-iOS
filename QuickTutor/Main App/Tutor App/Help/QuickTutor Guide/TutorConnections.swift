//
//  TutorConnections.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorConnectionsView : MainLayoutHeaderScroll {
    
    var connectingBody = SectionBody()
    var onceConnectedTitle = SectionTitle()
    var onceConnectedBody = SectionBody()
    
    override func configureView() {
        scrollView.addSubview(connectingBody)
        scrollView.addSubview(onceConnectedTitle)
        scrollView.addSubview(onceConnectedBody)
        super.configureView()
        
        title.label.text = "Connections"
        header.label.text = "Connecting"
        
        connectingBody.text = "After registration, the first step to connecting with a learner is fully filling out your profile, by tapping on the red progress on the home page. Once you list your preferences, policies, availability, and courses completed — you’ll be visible to learners.\n\nConnection requests will sent by learners through the messaging system, which can be sent with manually typed messages or custom messages.\n\nConnection requests that have not yet been accepted will appear in your “Learners” tab in the messenger. Once you accept a learner’s connection request, you’ll be able to communicate freely and schedule tutoring sessions. "
        
        onceConnectedTitle.label.text = "Once connected"
        onceConnectedBody.text = "Once you are connected with a learner, you can go to your “Learners” tab in the messenger. This is where you can see all your message threads with learners, which display the learner’s location or university, the past sessions you’ve had with them, their rating, and the last message sent between you two.\n\nTo message a learner, simply tap on their message thread in the “Learners” tab and your messages with them will open. Remember, until you accept a connection request, you will not be able to message a tutor freely."
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        connectingBody.constrainSelf(top: header.snp.bottom)
        onceConnectedTitle.constrainSelf(top: connectingBody.snp.bottom)
        onceConnectedBody.constrainSelf(top: onceConnectedTitle.snp.bottom)
    }
}

class TutorConnections : BaseViewController {
    
    override var contentView: TutorConnectionsView {
        return view as! TutorConnectionsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }
    
    override func loadView() {
        view = TutorConnectionsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
