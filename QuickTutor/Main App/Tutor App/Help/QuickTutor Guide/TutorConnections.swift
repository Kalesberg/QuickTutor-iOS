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
        
        connectingBody.text = "After tutor registration, you can connect with learners.\n\nLearners will send connection requests through the messenger, which will be delivered to you with manually typed messages or custom messages.\n\nConnection requests that have not yet been accepted will appear in your \"messages\" tab in the messenger. This is where you can see all your message threads with learners.  Once you accept a learner's connection request, you'll be able to communicate freely and schedule tutoring sessions."
        
        onceConnectedTitle.label.text = "Once connected"
        onceConnectedBody.text = "Once you are connected with a learner, you can go to your \"messages\" tab in the messenger. This is where you can see all your message threads with learners.\n\nTo message a learner, tap on their message thread in the \"messages\" tab and your messages with them will open. Remember, until you accept a connection request, you will not be able to message a learner freely, send images or schedule sessions."
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
