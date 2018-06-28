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
        
        strings = ["1.  Tap the three lines in the top left of the home page.\n", "2.  Tap the profile bar that displays your name and photo.\n", "3.  Tap \"Edit\" in the top right of the screen.\n", "4.  Select the the information you would like to change.\n", "5.  When you’ve changed your information, click save."]

		var attributesDictionary : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : infoChangeBody.font]
        var fullAttributedString = NSMutableAttributedString(string: "To update or change your name, biography, email, or languages you speak:\n\n", attributes: attributesDictionary)
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        infoChangeBody.attributedText = fullAttributedString
        
        infoChangeTitle.label.text = "INFO CHANGE"
        
        passwordTitle.label.text = "PASSWORD"
        passwordBody.text = "If you forget your password, please visit the Forgot your password page from the Accounts & Payments frame and follow the instructions."
        
        strings = ["1.  Tap the three lines in the top left of the home page.\n",
            "2.  Then, tap \"Edit\" in the top right of the screen.\n",
            "3.  You can add, change, or remove photos by selecting the \"+\" or \"x\".\n"]
        
        attributesDictionary = [NSAttributedStringKey.font : profilePictureBody.font]
        fullAttributedString = NSMutableAttributedString(string: "To change or add a profile picture:\n\n", attributes: attributesDictionary)
        
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            
            fullAttributedString.append(attributedString)
        }
        
        profilePictureBody.attributedText = fullAttributedString
        
        profilePictureTitle.label.text = "PROFILE PICTURE(S)"
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
