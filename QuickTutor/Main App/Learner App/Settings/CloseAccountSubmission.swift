//
//  CloseAccountSubmission.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class CloseAccountSubmissionView : MainLayoutTitleBackTwoButton, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    
    var submitButton = NavbarButtonSubmit()
    
    override var rightButton: NavbarButton {
        get {
            return submitButton
        } set {
            submitButton = newValue as! NavbarButtonSubmit
        }
    }
    
    let contentView = UIView()
    
    let reasonLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    let reasonContainer : UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.qtRed
        view.layer.cornerRadius = 5
        
        return view
    }()
    
    let helpLabel : UILabel = {
        let label = UILabel()
        
        label.text = "Is there anything we can do to help your experience?"
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(16)
        label.numberOfLines = 2
        
        return label
    }()
    
    let textView = SubmissionTextView()
    
    override func configureView() {
        addKeyboardView()
        addSubview(contentView)
        contentView.addSubview(reasonContainer)
        reasonContainer.addSubview(reasonLabel)
        contentView.addSubview(helpLabel)
        contentView.addSubview(textView)
        super.configureView()
        
        navbar.backgroundColor = Colors.qtRed
        statusbarView.backgroundColor = Colors.qtRed
        title.label.text = "Close Account"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        contentView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.equalTo(keyboardView.snp.top)
            make.centerX.equalToSuperview()
        }
        
        reasonContainer.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(15)
            make.width.equalTo(250)
            make.centerX.equalToSuperview()
            make.height.equalTo(55)
        }
        
        reasonLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        helpLabel.snp.makeConstraints { (make) in
            make.top.equalTo(reasonContainer.snp.bottom).inset(-15)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(helpLabel.snp.bottom).inset(-15)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().inset(40)
            make.centerX.equalToSuperview()
        }
    }
}


class SubmissionTextView : EditBioTextView {
    
    override func configureView() {
        addSubview(textView)
        
        backgroundColor = Colors.registrationDark
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 10
        
        applyConstraints()
    }
}


class CloseAccountSubmission : BaseViewController {
    
    override var contentView: CloseAccountSubmissionView {
        return view as! CloseAccountSubmissionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = CloseAccountSubmissionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        if(touchStartView is NavbarButtonSubmit) {
            
        }
    }
}
