//
//  RegistrationNavBarView.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class RegistrationNavBarView: RegistrationGradientView {
    var navBar       = RegistrationNavBar()
    var backButton   = RegistrationBackButton()
    var titleLabel   = RegistrationTitleLabel()
    var nextButton   = RegistrationNextButton()
    
    override func configureView() {
        super.configureView()
		
        addSubview(navBar)
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(nextButton)
		
    }
    
    override func applyConstraints() {
        navBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.06)
        }
        
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(navBar.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.1)
            make.left.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backButton.snp.bottom)
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.08)
        }
    }
}
