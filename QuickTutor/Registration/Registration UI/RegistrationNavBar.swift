//
//  RegistrationNavBar.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class ProgressBar : BaseView {
    
    var progressBar   = BaseView()
    var divider       = UIView()
    var remainderBar  = UIView()
    var topDivider    = UIView()
    var bottomDivider = UIView()
    
    var progress: CGFloat?
    
    override func configureView() {
        super.configureView()
        addSubview(progressBar)
        addSubview(divider)
        addSubview(remainderBar)
        addSubview(topDivider)
        addSubview(bottomDivider)
        
        divider.backgroundColor       = .black
        topDivider.backgroundColor    = .black
        bottomDivider.backgroundColor = .black
        progressBar.backgroundColor   = Colors.progressBlue
        remainderBar.backgroundColor  = Colors.remainderProgressDark
    
    }
    
    override func applyConstraints() {
        progressBar.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(self.progress!)
            make.height.equalToSuperview()
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        topDivider.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
        
        bottomDivider.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(1)
            make.centerX.equalToSuperview()
        }
        
        divider.snp.makeConstraints { (make) in
            make.top.equalTo(progressBar)
            make.height.equalTo(progressBar)
            make.width.equalTo(1)
            make.right.equalTo(progressBar.snp.right)
        }
        
        remainderBar.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.left.equalTo(divider.snp.right)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

class RegistrationNavBar: BaseView {
    var blackBar      = BaseView()
    var progressBar   = BaseView()
    var divider       = UIView()
    var remainderBar  = UIView()
    var topDivider    = UIView()
    var bottomDivider = UIView()
    
    var progress: CGFloat?
    
    override func configureView() {
        super.configureView()
        addSubview(blackBar)
        addSubview(progressBar)
        addSubview(divider)
        addSubview(remainderBar)
        addSubview(topDivider)
        addSubview(bottomDivider)
        
        divider.backgroundColor       = .black
        topDivider.backgroundColor    = .black
        bottomDivider.backgroundColor = .black
        
        blackBar.backgroundColor      = Colors.registrationDark
        progressBar.backgroundColor   = Colors.progressBlue
        remainderBar.backgroundColor  = Colors.remainderProgressDark
    }
    
    override func applyConstraints() {
        blackBar.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.top.equalTo(0)
        }
        
        progressBar.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(self.progress!)
            make.height.equalToSuperview().multipliedBy(0.1)
            make.bottom.equalTo(blackBar.snp.bottom).offset(-1)
        }
        
        topDivider.snp.makeConstraints { (make) in
            make.top.equalTo(progressBar.snp.top).offset(-1)
            make.width.equalToSuperview()
            make.height.equalTo(1)
        }
        
        bottomDivider.snp.makeConstraints { (make) in
            make.bottom.equalTo(blackBar)
            make.width.equalToSuperview()
            make.height.equalTo(1)
        }
        
        divider.snp.makeConstraints { (make) in
            make.top.equalTo(progressBar)
            make.height.equalTo(progressBar)
            make.width.equalTo(1)
            make.left.equalTo(progressBar.snp.right)
        }
        
        remainderBar.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.1)
            make.left.equalTo(divider.snp.right)
            make.right.equalToSuperview()
            make.bottom.equalTo(blackBar.snp.bottom).offset(-1)
        }
    }
}
