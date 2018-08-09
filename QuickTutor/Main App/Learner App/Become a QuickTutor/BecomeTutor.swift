//
//  CrossoverPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import Foundation
import UIKit


class StartButton : InteractableBackgroundView {
    
    var label = UILabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        label.text = "Start Tutoring"
        label.textColor = Colors.registrationDark
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(18)
        
        backgroundColor = .white
        layer.cornerRadius = 5
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}


class BecomeTutorView : BaseLayoutView {
    
    var backButton = RegistrationBackButton()
    var becomeQTLabel = UILabel()
    var container = UIView()
    var bottom = UIView()
    var startButton = StartButton()
    var makeMoneyLabel = UILabel()
    var scrollView = UIScrollView()
    var earnMoneyTitle = SectionTitle()
    var earnMoneyBody = SectionBody()
    var userFreedomTitle = SectionTitle()
    var userFreedomBody = SectionBody()
    var safetyMattersTitle = SectionTitle()
    var safetyMattersBody = SectionBody()
    
    override func configureView() {
        addSubview(backButton)
        addSubview(becomeQTLabel)
        addSubview(bottom)
        addSubview(container)
        container.addSubview(startButton)
        container.addSubview(makeMoneyLabel)
        addSubview(scrollView)
        scrollView.addSubview(earnMoneyTitle)
        scrollView.addSubview(earnMoneyBody)
        scrollView.addSubview(userFreedomTitle)
        scrollView.addSubview(userFreedomBody)
        scrollView.addSubview(safetyMattersTitle)
        scrollView.addSubview(safetyMattersBody)
        super.configureView()
        
        bottom.backgroundColor = Colors.registrationDark
        container.backgroundColor = Colors.registrationDark
        
        becomeQTLabel.textColor = .white
        becomeQTLabel.text = "Become a QuickTutor"
        becomeQTLabel.font = Fonts.createBoldItalicSize(26)
        
        makeMoneyLabel.text = "Make money teaching the things you're good at!"
        makeMoneyLabel.textColor = .white
        makeMoneyLabel.font = Fonts.createSize(15)
        makeMoneyLabel.numberOfLines = 0
        
        earnMoneyTitle.label.text = "Earn money tutoring"
        
        earnMoneyBody.text = "No matter who you are, QuickTutor enables you to simply run a freelance tutoring business. QuickTutor makes it simple and safe to earn money and teach people around the world - either in-person with people near you or video call globally."
        
        userFreedomTitle.label.text = "User Freedom"
        userFreedomBody.text = "With QuickTutor, you are in complete control of your schedule, hourly rate, preferences, policies, and how you communicate with learners."
        
        safetyMattersTitle.label.text = "Your Safety Matters"
        safetyMattersBody.text = "QuickTutor has a rating, review, and reporting system to ensure your safety as a tutor. Remember to fully analyze a learner's profile before meeting up with them in-person."
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        backButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(DeviceInfo.statusbarHeight)
            }
            make.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.1)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        
        becomeQTLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backButton.snp.bottom)
            make.height.equalTo(30)
            make.left.equalTo(backButton.button.snp.left).inset(5)
            make.right.equalToSuperview()
        }
        
        bottom.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.height.equalTo(0)
            }
        }
        
        container.snp.makeConstraints { (make) in
            make.bottom.equalTo(bottom.snp.top)
            make.height.equalTo(100)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        startButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(20)
            make.width.equalTo(130)
            make.height.equalTo(60)
        }
        
        makeMoneyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(startButton.snp.right).inset(-20)
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.bottom.equalTo(container.snp.top)
            make.left.equalToSuperview().inset(15)
            make.right.equalToSuperview()
            make.top.equalTo(becomeQTLabel.snp.bottom).inset(-15)
        }
        
        earnMoneyTitle.constrainSelf(top: scrollView.snp.top)
        
        earnMoneyBody.constrainSelf(top: earnMoneyTitle.snp.bottom)
        
        userFreedomTitle.constrainSelf(top: earnMoneyBody.snp.bottom)
        
        userFreedomBody.constrainSelf(top: userFreedomTitle.snp.bottom)
        
        safetyMattersTitle.constrainSelf(top: userFreedomBody.snp.bottom)
        
        safetyMattersBody.constrainSelf(top: safetyMattersTitle.snp.bottom)
    }
}


class BecomeTutor : BaseViewController {
    
    override var contentView: BecomeTutorView {
        return view as! BecomeTutorView
    }
    
    override func loadView() {
        view = BecomeTutorView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layoutIfNeeded()
        contentView.scrollView.contentSize = CGSize(width: 280, height: contentView.safetyMattersBody.frame.maxY - contentView.earnMoneyTitle.frame.minY)
        contentView.applyGradient(firstColor: UIColor(hex:"2c467c").cgColor, secondColor: Colors.oldTutorBlue.cgColor, angle: 200, frame: contentView.bounds)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        if(touchStartView is RegistrationBackButton) {
            AccountService.shared.currentUserType = .learner
            navigationController?.popViewController(animated: true)
        } else if(touchStartView is StartButton) {
            navigationController?.pushViewController(TutorAddSubjects(), animated: true)
        }
    }
}
