//
//  BaseModalXibView.swift
//  QuickTutor
//
//  Created by Will Saults on 4/28/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

protocol BaseModalXibViewDelegate {
    func didDismiss()
}

class BaseModalXibView: UIView {
    
    var delegate: BaseModalXibViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        self.alpha = 0
        
        if let window = UIApplication.shared.windows.last {
            layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
            frame = window.bounds
            window.addSubview(self)
        }
        
        show()
    }
    
    func show() {
        fadeIn(true)
    }
    
    @objc func dismiss() {
        delegate?.didDismiss()
        fadeIn(false)
    }
    
    private func fadeIn(_ appear: Bool, duration: TimeInterval = 0.5, delay: TimeInterval = 0.0) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = appear ? 1.0 : 0.0
        }, completion: { (finished: Bool) in
            if !appear {
                self.removeFromSuperview()
            }
        })
    }
    
    func setParagraphStyle(label: UILabel?) {
        let attributedString = NSMutableAttributedString(string: label?.text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        label?.attributedText = attributedString
    }
}

@IBDesignable
class RoundedView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
}
