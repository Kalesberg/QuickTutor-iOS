//
//  LearnerMainPageAnimationController.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class LearnerMainPageAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let originalFrame: CGRect
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else { return }
        
        let snapshot = UIImageView(image:toVC.view.snapshotImage)
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        snapshot.frame = originalFrame
        snapshot.layer.cornerRadius = 4
        snapshot.layer.masksToBounds = true
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        toVC.view.isHidden = true
        
        
        let duration = transitionDuration(using: transitionContext)
        
        // 1
        UIView.animate(withDuration: duration, animations: {
            snapshot.frame = finalFrame
        }) { (completed) in
            toVC.view.isHidden = false
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
    
    init(originalFrame: CGRect) {
        self.originalFrame = originalFrame
    }
    
    
    
}


struct AnimationHelper {
    static func yRotation(_ angle: Double) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle), 0.0, 1.0, 0.0)
    }
    
    static func perspectiveTransform(for containerView: UIView) {
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
    }
}


//extension LearnerMainPageVC {
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        let cell = selectedCell!
//        let testFrame = cell.convert(cell.frame, to: nil)
//
//        let newFrame = CGRect(x: cell.frame.minX, y: testFrame.minY - 20, width: cell.frame.width, height: cell.frame.height)
//
//        return LearnerMainPageAnimationController(originalFrame: newFrame)
//
//    }
//}

private extension UIView {
    var snapshotImage: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
