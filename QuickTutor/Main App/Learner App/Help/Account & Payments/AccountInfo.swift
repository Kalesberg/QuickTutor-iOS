//
//  AccountInformation.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class AccountInfoView : MainLayoutHeaderScroll {
    
    var infoChangeTitle = SectionTitle()
    var infoChangeBody = SectionBody()
    var passwordTitle = SectionTitle()
    var passwordBody = SectionBody()
    var profilePictureTitle = SectionTitle()
    var profilePictureBody = SectionBody()
    var strings: [String] = []
    
    override func configureView() {
        scrollView.addSubview(infoChangeTitle)
        scrollView.addSubview(infoChangeBody)
        scrollView.addSubview(passwordTitle)
        scrollView.addSubview(passwordBody)
        scrollView.addSubview(profilePictureTitle)
        scrollView.addSubview(profilePictureBody)
        super.configureView()
        
        title.label.text = "Help"
        header.label.text = "Changing my account setttings"
        
        strings = ["1.  Select the navigation bar in the main app menu.\n", "2.  Tap the profile bar that displays your information.\n", "3.  Tap \"Edit\" in the top right of the screen.\n", "4.  Select the the information you would like to change.\n", "5.  When you’ve changed your information, click save."]

        let attributesDictionary = [NSAttributedStringKey.font : infoChangeBody.font]
        let fullAttributedString = NSMutableAttributedString(string: "To update or change your name, biography, email, place of work, university, or languages you speak:\n\n", attributes: attributesDictionary)
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        infoChangeBody.attributedText = fullAttributedString
        
        infoChangeTitle.label.text = "INFO CHANGE"
        
        passwordTitle.label.text = "PASSWORD"
        passwordBody.text = "If you change your password, you’ll receive a verification code via text message. Enter the code in your app to confirm the change.\n\nIf you change your password, you’ll be prompted to enter your current password. Passwords must be at least eight characters long."
        
        profilePictureTitle.label.text = "PROFILE PICTURE(S)"
        profilePictureBody.text = "To change or add a profile picture, select your profile bar from the navigation menu or settings tab and then tap “Edit” in the top right of the screen. You can add, replace, or remove photos by selecting the “+” or “x”.\n\n"
        
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        infoChangeTitle.constrainSelf(top: header.snp.bottom)
        
        infoChangeBody.constrainSelf(top: infoChangeTitle.snp.bottom)
        
        passwordTitle.constrainSelf(top: infoChangeBody.snp.bottom)
        
        passwordBody.constrainSelf(top: passwordTitle.snp.bottom)
        
        profilePictureTitle.constrainSelf(top: passwordBody.snp.bottom)
        
        profilePictureBody.constrainSelf(top: profilePictureTitle.snp.bottom)
    }
}


class AccountInfo : BaseViewController {
    
    override var contentView: AccountInfoView {
        return view as! AccountInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
    }
    
    override func loadView() {
        view = AccountInfoView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
