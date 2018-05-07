//
//  RegistrationNavBarView.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class RegistrationNavBarView: RegistrationGradientView {

    var statusbarView = UIView()
    var progressBar   = ProgressBar()
    var backButton    = RegistrationBackButton()
    var titleLabel    = RegistrationTitleLabel()
    var nextButton    = RegistrationNextButton()
    
    override func configureView() {
        super.configureView()
        addSubview(statusbarView)
        addSubview(progressBar)
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(nextButton)
        
        statusbarView.backgroundColor = Colors.registrationDark
    }
    
    override func applyConstraints() {
        
        statusbarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top)
        }
        
        progressBar.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.height.equalTo(8)
            make.top.equalTo(statusbarView.snp.bottom)
        }
        
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(progressBar.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.09)
            make.left.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backButton.snp.bottom)
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.07)
        }
    }
}
