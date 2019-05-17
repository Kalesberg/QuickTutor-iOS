//
//  QTQuickCallModalAnimator.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 5/16/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
class QTQuickCallModalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.0
    var presenting = true
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if let toView = transitionContext.view(forKey: .to) {
            toView.alpha = 0.0
            UIView.animate(withDuration: duration,
                           animations: {
                            toView.alpha = 1.0
            },
                           completion: { _ in
                            transitionContext.completeTransition(true)
            })
        }
    }
}
