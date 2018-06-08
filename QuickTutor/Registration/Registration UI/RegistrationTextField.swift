//
//  RegistrationTextField.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit

class RegistrationTextField: BaseView {
    
    var placeholder = UILabel()
    var textField   = NoPasteTextField()
    var line        = UIView()

    override func configureView() {
        addSubview(placeholder)
        addSubview(textField)
        addSubview(line)
        
        placeholder.textColor = .white
        placeholder.textAlignment = .left
        placeholder.numberOfLines = 1
        placeholder.font = Fonts.createSize(14)
        
        textField.font = Fonts.createSize(CGFloat(DeviceInfo.textFieldFontSize))
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.tintColor = .white
        textField.adjustsFontSizeToFitWidth = true
        textField.adjustsFontForContentSizeCategory = true
        
        line.backgroundColor = .white
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        
        placeholder.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        line.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.8)
        }
        
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.35)
        }
    }
}

class SearchTextField : RegistrationTextField {
    let imageView : UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "searchIcon")
        view.scaleImage()
        
        return view
    }()
    
    
    override func configureView() {
        addSubview(imageView)
        super.configureView()
        
    }
    
    override func applyConstraints() {
        placeholder.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        line.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.8)
        }
        
        imageView.snp.makeConstraints({ (make) in
            make.left.equalToSuperview()
            make.centerY.equalTo(textField)
            make.height.width.equalTo(15)
        })
        
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).inset(-10)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.35)
        }
    }
}

