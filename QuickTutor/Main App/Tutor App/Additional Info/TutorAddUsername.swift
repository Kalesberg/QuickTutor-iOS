//
//  TutorAddUsername.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorAddUsernameTextfield : InteractableView {
    
    let headerLabel : UILabel = {
        let label = UILabel()
        
        label.text = "QuickTutor Username"
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        
        return label
    }()
    
    let infoLabel : UILabel = {
        let label = UILabel()
        
        label.text = "Having a unique username will help learners find you."
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(14)
        label.numberOfLines = 0
        
        return label
    }()
    
    let textField : NoPasteTextField = {
        let textField = NoPasteTextField()
        
        textField.font = Fonts.createSize(22)
        textField.textColor = .white
        textField.isEnabled = true
        textField.tintColor = .white
        
        return textField
    }()
    
    let characterLabel : UILabel = {
        let label = UILabel()
        
        label.text = "Must not be longer than 15 characters."
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(18)
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    let line = UIView()
    
    override func configureView() {
        addSubview(headerLabel)
        addSubview(infoLabel)
        addSubview(textField)
        addSubview(line)
        addSubview(characterLabel)
        super.configureView()
        
        line.backgroundColor = .white
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        headerLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        textField.snp.makeConstraints { (make) in
            make.width.equalTo(headerLabel)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(infoLabel.snp.bottom).inset(-5)
        }
        
        line.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        characterLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).inset(-15)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}


class TutorAddUsernameView : TutorPreferencesLayout, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    
    let contentView = UIView()
    let textField = TutorAddUsernameTextfield()
    
    override func configureView() {
        addKeyboardView()
        addSubview(contentView)
        contentView.addSubview(textField)
        contentView.addSubview(nextButton)
        super.configureView()
        
        title.label.text = "Create a Username"
        
        addSubview(progressBar)
        progressBar.progress = 0.8
        progressBar.applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        contentView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom).inset(8)
            make.bottom.equalTo(keyboardView.snp.top)
        }
        
        textField.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(-50)
            make.height.equalTo(120)
            make.width.equalToSuperview().multipliedBy(0.85)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
        }
    }
}


class TutorAddUsername : BaseViewController {
    
    override var contentView: TutorAddUsernameView {
        return view as! TutorAddUsernameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.textField.textField.becomeFirstResponder()
    }
    override func loadView() {
        view = TutorAddUsernameView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func handleNavigation() {
        if (touchStartView is TutorPreferencesNextButton) {
            print("sdf")
            //navigationController?.pushViewController(, animated: <#T##Bool#>)
        }
    }
}
