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
    var connectingBody              = SectionBody()
    var addingTutorsTitle           = SectionTitle()
    var addingTutorsBody            = SectionBody()
    var connectingNameTitle         = SectionTitle()
    var connectingNameBody          = SectionBody()
    var onceConnectedTitle          = SectionTitle()
    var onceConnectedBody           = SectionBody()
    
    
    override func configureView() {
        scrollView.addSubview(connectingBody)
        scrollView.addSubview(addingTutorsTitle)
        scrollView.addSubview(addingTutorsBody)
        scrollView.addSubview(connectingNameTitle)
        scrollView.addSubview(connectingNameBody)
        scrollView.addSubview(onceConnectedTitle)
        scrollView.addSubview(onceConnectedBody)
        
        
        super.configureView()

        header.label.text = "Connecting with tutors"

        connectingBody.text = "The first step to learning from a tutor is connecting with them. To connect with a tutor, tap the violet \"Connect\" button located in the bottom right corner of the footer on a tutor’s profile.\n\nConnection requests can be sent with manually typed messages or custom messages. You’ll be unable to message a tutor again until they accept your connection request so be sure to make a good first impression (no pressure)."

        addingTutorsTitle.label.text = "Searching by username"
        addingTutorsBody.text = "If you meet a QuickTutor or person outside of the app, and would like to connect with them, you can search their name or username in the \"all\" or “people” section of search in your home tab."

        connectingNameTitle.label.text = "Connecting via username [Sort’ve a shortcut!]"
        connectingNameBody.text = "To instantly connect with people via username - you can go into your messages tab, tap on the contacts icon (top right corner) and then tap the add button in the top right corner of the screen. Once here, you can enter the username of any user and view their profiles or connect with them."
        
        onceConnectedTitle.label.text = "Once connected"
        var attributesDictionary: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: onceConnectedBody.font]
        var fullAttributedText = NSMutableAttributedString(string: "Once you’re connected with a tutor, you can send messages, documents, photos, and videos back and forth. In addition to this, your ", attributes: attributesDictionary)
        fullAttributedText.append(NSAttributedString(string: "connect", attributes: [.font: UIFont.qtBoldItalicFont(size: 14)]))
        fullAttributedText.append(NSAttributedString(string: " button will turn into a ", attributes: attributesDictionary))
        fullAttributedText.append(NSAttributedString(string: "request session", attributes: [.font: UIFont.qtBoldItalicFont(size: 14)]))
        fullAttributedText.append(NSAttributedString(string: " button. You will now have the capability to schedule in-person and online learning sessions by tapping the “request session” button.", attributes: attributesDictionary))
        
        onceConnectedBody.attributedText = fullAttributedText
        
        
    }

    override func applyConstraints() {
        super.applyConstraints()

        connectingBody.constrainSelf(top: header.snp.bottom)
        addingTutorsTitle.constrainSelf(top: connectingBody.snp.bottom)
        addingTutorsBody.constrainSelf(top: addingTutorsTitle.snp.bottom)
        connectingNameTitle.constrainSelf(top: addingTutorsBody.snp.bottom, true)
        connectingNameBody.constrainSelf(top: connectingNameTitle.snp.bottom, 10)
        onceConnectedTitle.constrainSelf(top: connectingNameBody.snp.bottom)
        onceConnectedBody.constrainSelf(top: onceConnectedTitle.snp.bottom)
        
        
    }
}

class Connections: BaseViewController {
    override var contentView: ConnectionsView {
        return view as! ConnectionsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Connecting"
        contentView.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = ConnectionsView()
    }

    override func handleNavigation() {}
}
