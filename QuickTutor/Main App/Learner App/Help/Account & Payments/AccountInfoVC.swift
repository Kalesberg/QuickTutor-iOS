//
//  AccountInformation.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class AccountInfoView: MainLayoutHeaderScroll {
    var infoChangeTitle = SectionTitle()
    var infoChangeBody = SectionBody()
    var infoChangeFooter = SectionBody()
    var passwordTitle = SectionTitle()
    var passwordBody = SectionBody()
    var profilePictureTitle = SectionTitle()
    var profilePictureSubTitle = SectionSubTitle()
    var profilePictureBody = SectionBody()
    var strings: [String] = []

    override func configureView() {
        scrollView.addSubview(infoChangeTitle)
        scrollView.addSubview(infoChangeBody)
        scrollView.addSubview(infoChangeFooter)
        scrollView.addSubview(passwordTitle)
        scrollView.addSubview(passwordBody)
        scrollView.addSubview(profilePictureTitle)
        scrollView.addSubview(profilePictureBody)
        super.configureView()

        header.label.text = "Changing my account information"

        infoChangeTitle.label.text = "Info changes"
        
        var attributesDictionary: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: infoChangeBody.font]
        var fullAttributedString = NSMutableAttributedString(string: "To update or change your name, biography, email or the languages you speak:\n\n", attributes: attributesDictionary)
        
        strings = ["1.  Tap the profile icon in the bottom right corner of your screen (on your tab bar).\n\n", "2.  Tap \"view profile\" which is located just above your switch mode button (learner mode button). \n\n", "3.  Tap the pencil icon in the top right corner of your screen.\n\n", "4.  Tap on any information you’d like to change and then tap the checkmark when you are finished making changes.\n"]

        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)

            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))

            fullAttributedString.append(attributedString)
        }

        infoChangeBody.attributedText = fullAttributedString
        infoChangeFooter.text = "You can add up to eight photos, two languages and one university to your profile."

        passwordTitle.label.text = "Password"
        attributesDictionary = [NSAttributedString.Key.font: passwordBody.font]
        fullAttributedString = NSMutableAttributedString(string: "If you forget your password, please visit the ", attributes: attributesDictionary)
        fullAttributedString.append(NSAttributedString(string: "forgot your password", attributes: [.font : UIFont.qtBoldItalicFont(size: 14)]))
        
        fullAttributedString.append(NSAttributedString(string: " page from the Accounts & Payments help menu (previous screen) and follow the instructions detailed there.", attributes: attributesDictionary))
        passwordBody.attributedText = fullAttributedString

        profilePictureTitle.label.text = "Profile picture(s)"
        
        attributesDictionary = [NSAttributedString.Key.font: UIFont.qtBoldFont(size: 14)]
        fullAttributedString = NSMutableAttributedString(string: "To change or add a profile picture:\n\n", attributes: attributesDictionary)

        strings = ["1.  Tap the profile icon in the bottom right corner of your screen (on your tab bar).\n\n",
                   "2.  Tap \"view profile\" which is located just above \"learner mode\".\n\n",
                   "3.  Tap on any photo(s) or circle icons with a plus symbol and then select \"take photo\",\"camera roll\" or \"remove\" to select a photo to upload or remove a photo.\n\n"]
        
        attributesDictionary = [NSAttributedString.Key.font: profilePictureBody.font]
        for string: String in strings {
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string)

            let paragraphStyle = createParagraphAttribute()
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))

            fullAttributedString.append(attributedString)
        }

        profilePictureBody.attributedText = fullAttributedString

        
    }

    override func applyConstraints() {
        super.applyConstraints()

        infoChangeTitle.constrainSelf(top: header.snp.bottom)

        infoChangeBody.constrainSelf(top: infoChangeTitle.snp.bottom)
        
        infoChangeFooter.constrainSelf(top: infoChangeBody.snp.bottom)

        passwordTitle.constrainSelf(top: infoChangeFooter.snp.bottom)

        passwordBody.constrainSelf(top: passwordTitle.snp.bottom)

        profilePictureTitle.constrainSelf(top: passwordBody.snp.bottom)

        profilePictureBody.constrainSelf(top: profilePictureTitle.snp.bottom)
    }
}

class AccountInfoVC: BaseViewController {
    override var contentView: AccountInfoView {
        return view as! AccountInfoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Info changes"
        contentView.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.scrollView.setContentSize()
    }

    override func loadView() {
        view = AccountInfoView()
    }

}
