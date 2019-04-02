//
//  TutorPolicyVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/16/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorPolicyVCView: BaseRegistrationView {
    
    let scrollView: UIScrollView = {
        var sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.canCancelContentTouches = true
        sv.isDirectionalLockEnabled = true
        sv.isExclusiveTouch = false
        return sv
    }()
    
    let contentLabel: UILabel = {
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("Your relationship with QuickTutor\n\n", 15, .white)
            .regular("On QuickTutor, you're an independent tutor in full control of your business. You have the freedom to choose which opportunities to pursue, when you want to tutor, and how much you charge.\n\n", 13, Colors.registrationGray, 8.0)
            .bold("Communicate through the app\n\n", 15, .white)
            .regular("The QuickTutor messaging system allows you to communicate and set up tutoring sessions, without having to give away any personal or private information like your phone number or email. Keep your conversations in the messaging system to protect yourself.\n\n", 13, Colors.registrationGray, 8.0)
            .bold("The ultimate biz management tool\n\n", 15, .white)
            .regular("With QuickTutor, you'll be able to schedule and facilitate your in-person and online sessions through the app, and recieve instant payments for tutoring. Make sure to keep your sessions through the app to avoid not being paid on time, not being paid at all, or not revieving a rating.", 13, Colors.registrationGray, 8.0)
        
        var label = UILabel()
        label.sizeToFit()
        label.numberOfLines = 0
        label.attributedText = formattedString
        return label
    }()
    
    let bottomView: UIView = {
        var view = UIView()
        view.backgroundColor = Colors.darkBackground
        view.layer.shadowOffset = CGSize(width: 0, height: -5)
        view.layer.shadowRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        return view
    }()
    
    let independentTutorButton: ArrowItem = {
        var item = ArrowItem()
        item.label.text = "Independent Tutor Agreement"
        item.divider.isHidden = true
        item.backgroundColor = Colors.darkBackground
        return item
    }()
    
    let line: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray
        view.layer.cornerRadius = 0.5
        return view
    }()
    
    let checkBoxLabel: UILabel = {
        var label = UILabel()
        label.font = Fonts.createSize(10)
        label.textColor = Colors.grayText
        label.text = "By checking the box, you confirm that you have reviewed the document above and you agree to its terms."
        label.numberOfLines = 0
        return label
    }()
    
    let checkBox: UIButton = {
        var button = UIButton()
        button.isSelected = false
        button.setImage(UIImage(named: "registration-checkbox-unselected"), for: .normal)
        button.setImage(UIImage(named: "registration-checkbox-selected"), for: .selected)
        return button
    }()
    
    var contentLabelHeightAnchor: NSLayoutConstraint?
    var bottomViewHeightAnchor: NSLayoutConstraint?
    
    override func setupViews() {
        super.setupViews()
        setupScrollView()
        setupContentLabel()
        setupBottomView()
        setupCheckBox()
        setupCheckBoxLabel()
        setupIndependentTutorButton()
        setupLine()
    }
    
    func setupScrollView() {
        addSubview(scrollView)
        scrollView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 30, paddingBottom: 128, paddingRight: 30, width: 0, height: 0)
    }
    
    func setupContentLabel() {
        scrollView.addSubview(contentLabel)
        contentLabel.anchor(top: scrollView.topAnchor, left: leftAnchor, bottom: scrollView.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 0)
        contentLabelHeightAnchor = contentLabel.heightAnchor.constraint(equalToConstant: 525)
        contentLabelHeightAnchor?.isActive = true
    }
    
    func setupBottomView() {
        addSubview(bottomView)
        bottomView.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        bottomViewHeightAnchor = bottomView.heightAnchor.constraint(equalToConstant: 128)
        bottomViewHeightAnchor?.isActive = true
    }
    
    func setupCheckBox() {
        addSubview(checkBox)
        checkBox.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 26, paddingRight: 0, width: 20, height: 20)
    }
    
    func setupCheckBoxLabel() {
        addSubview(checkBoxLabel)
        checkBoxLabel.anchor(top: nil, left: checkBox.rightAnchor, bottom: bottomView.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 30, width: 0, height: 30)
    }
    
    func setupIndependentTutorButton() {
        addSubview(independentTutorButton)
        independentTutorButton.anchor(top: bottomView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 57)
    }
    
    func setupLine() {
        addSubview(line)
        line.anchor(top: independentTutorButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 1)
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "QuickTutor Agreement"
    }
}
