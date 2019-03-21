//
//  BecomeTutorVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class BecomeTutorVCView: TutorPolicyVCView {
    
    override func setupViews() {
        super.setupViews()
        updateContentLabel()
        independentTutorButton.removeFromSuperview()
        line.removeFromSuperview()
        checkBox.removeFromSuperview()
        checkBoxLabel.removeFromSuperview()
        setupNextButton()
        setupInfoLabel()
    }
    
    let nextButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.purple
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.setTitle("START TUTORING", for: .normal)
        button.layer.cornerRadius = 4
        return button
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Earn money teaching the things you're good at!"
        label.numberOfLines = 0
        label.font = Fonts.createSize(14)
        label.textColor = Colors.registrationGray
        return label
    }()
    
    func setupNextButton() {
        addSubview(nextButton)
        nextButton.anchor(top: nil, left: leftAnchor, bottom: bottomView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 30, paddingBottom: 30, paddingRight: 0, width: 145, height: 45)
    }
    
    func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.anchor(top: nil, left: nextButton.rightAnchor, bottom: nextButton.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 45)
    }
    
    func updateContentLabel() {
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("Earn money tutoring\n\n", 15, .white)
            .regular("No matter who you are, QuickTutor enables you to simply run a freelance tutoring business. QuickTutor makes it safe and straightforward to earn money and teach people around the world - either in-person with people near you or through video calling, globally.\n\n", 13, Colors.registrationGray, 8.0)
            .bold("User Freedom\n\n", 15, .white)
            .regular("With QuickTutor, you are in complete control of your schedule, hourly rate, preferences, policies, and how you communicate with learners.\n\n", 13, Colors.registrationGray, 8.0)
            .bold("Your Safety Matters\n\n", 15, .white)
            .regular("QuickTutor has a rating, reviewing and reporting system to ensure your safety as a tutor. Remember to thoroughly analyze a learner's profile before meeting up with them in-person.", 13, Colors.registrationGray, 8.0)
        contentLabel.attributedText = formattedString
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "Become a QuickTutor"
    }
    
    override func setupContentLabel() {
        super.setupContentLabel()
        contentLabelHeightAnchor?.constant = 450
        contentLabel.layoutIfNeeded()
    }
    
    override func setupBottomView() {
        super.setupBottomView()
        bottomViewHeightAnchor?.constant = 80
        bottomView.layoutIfNeeded()
    }
}
