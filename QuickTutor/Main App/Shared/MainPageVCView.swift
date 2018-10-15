//
//  MainPageVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class MainPageVCView: MainLayoutTwoButton {
    var sidebarButton = NavbarButtonLines()
    var messagesButton = NavbarButtonMessages()
    var backgroundView = InteractableObject()
    
    override var leftButton: NavbarButton {
        get {
            return sidebarButton
        } set {
            sidebarButton = newValue as! NavbarButtonLines
        }
    }
    
    override var rightButton: NavbarButton {
        get {
            return messagesButton
        } set {
            messagesButton = newValue as! NavbarButtonMessages
        }
    }
    
    var sidebar = Sidebar()
    
    override func configureView() {
        addSubview(backgroundView)
        
        navbar.addSubview(sidebarButton)
        navbar.addSubview(messagesButton)
        let circle = UIView()
        circle.backgroundColor = Colors.notificationRed
        circle.layer.borderColor = Colors.currentUserColor().cgColor
        circle.layer.borderWidth = 2
        circle.layer.cornerRadius = 7
        circle.isHidden = true
        circle.layer.zPosition = .greatestFiniteMagnitude
        navbar.addSubview(circle)
        circle.anchor(top: messagesButton.topAnchor, left: nil, bottom: nil, right: messagesButton.rightAnchor, paddingTop: -1, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 14, height: 14)
        bringSubviewToFront(circle)
        DataService.shared.checkUnreadMessagesForUser { hasUnreadMessages in
            circle.isHidden = !hasUnreadMessages
        }
        
        insertSubview(sidebar, aboveSubview: navbar)
        super.configureView()
        
        backgroundView.alpha = 0.0
        
        sidebar.alpha = 0.0
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.isUserInteractionEnabled = false
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(blurEffectView)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        sidebarButton.allignLeft()
        messagesButton.allignRight()
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        sidebar.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.72)
        }
    }
    
    
}
