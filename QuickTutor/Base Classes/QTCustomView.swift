//
//  CustomView.swift
//
//  Created by JH Lee on 11/15/16.
//  Copyright © 2016 developer. All rights reserved.
//

import UIKit

@IBDesignable class QTCustomView: UIView {
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
}
