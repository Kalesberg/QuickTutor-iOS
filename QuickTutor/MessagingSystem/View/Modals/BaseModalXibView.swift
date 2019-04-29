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
    
    func dismiss() {
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
}
