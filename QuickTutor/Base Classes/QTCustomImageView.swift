//
//  QTCustomImageView.swift
//  QuickTutor
//
//  Created by Michael Burkard on 1/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

@IBDesignable class QTCustomImageView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            draw(frame)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            draw(frame)
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            draw(frame)
        }
    }
    
    @IBInspectable var overlayColor: UIColor = UIColor.clear {
        didSet {
            draw(frame)
        }
    }
    
    override func draw(_ rect: CGRect) {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        
        if overlayColor != UIColor.clear {
            self.image = self.image!.withRenderingMode(.alwaysTemplate)
            self.tintColor = overlayColor
        }
    }
}
