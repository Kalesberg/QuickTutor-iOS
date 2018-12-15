//
//  RegistrationTextField.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit

class RegistrationTextField: UIView {
    
    let placeholder: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = Fonts.createSize(14)
        return label
    }()
    
    let textField: NoPasteTextField = {
        let field = NoPasteTextField()
        field.font = Fonts.createSize(16)
        field.keyboardAppearance = .dark
        field.textColor = .white
        field.tintColor = .white
        field.adjustsFontSizeToFitWidth = true
        field.adjustsFontForContentSizeCategory = true
        return field
    }()

    let line = UIView()
    
    func setupViews() {
        setupPlaceholder()
        setupTextField()
        setupLine()
    }
    
    func setupPlaceholder() {
        addSubview(placeholder)
        placeholder.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
    }
    
    func setupTextField() {
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(40)
            make.centerY.equalToSuperview().multipliedBy(1.35)
        }
    }
    
    func setupLine() {
        addSubview(line)
        line.backgroundColor = Colors.gray
        line.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.8)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SearchTextField: RegistrationTextField {
    let imageView: UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "searchIcon")
        view.scaleImage()
        
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(imageView)
        placeholder.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        line.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.8)
        }
        
        imageView.snp.makeConstraints({ make in
            make.left.equalToSuperview()
            make.centerY.equalTo(textField)
            make.height.width.equalTo(15)
        })
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).inset(-10)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.35)
        }
    }

}
