//
//  RegistrationDigitTextField.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/10/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit

@IBDesignable
class RegistrationDigitTextField : UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureTextField()
    }
    internal override init(frame: CGRect){
        super.init(frame: frame)
        configureTextField()
    }
    internal override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureTextField()
    }
    
    func configureTextField() {
        font = Font.sharedFontsManager.toLato(size: 20)
        keyboardAppearance = .dark
        textColor = UIColor.white
        backgroundColor = UIColor.clear
        borderStyle = .none
        tintColor = .white
        
        let border = CALayer()
        let width = CGFloat(0.9)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: frame.size.height - width, width:  frame.size.width, height: frame.size.height)
        border.borderWidth = width
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
}
