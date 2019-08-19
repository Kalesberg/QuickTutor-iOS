//
//  QTBaseCustomDialog.swift
//  QuickTutor
//
//  Created by Michael Burkard on 8/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

enum CustomAnimatorStyle {
    case presenting, dismissing
}

class CustomDialogAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var animationStyle: CustomAnimatorStyle?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if let animationStyle = animationStyle {
            if .presenting == animationStyle {
                if let toVC = transitionContext.viewController(forKey: .to) as? QTBaseCustomDialog {
                    containerView.addSubview(toVC.view)
                    toVC.view.frame = containerView.frame
                    
                    toVC.constraintContentViewBottom?.constant = -toVC.view.bounds.size.height
                    
                    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                        toVC.constraintContentViewBottom?.constant = 0
                        toVC.view.layoutIfNeeded()
                    }, completion: { (completed) in
                        transitionContext.completeTransition(completed)
                    })
                }
            } else {
                if let fromVC = transitionContext.viewController(forKey: .from) as? QTBaseCustomDialog {
                    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                        fromVC.constraintContentViewBottom?.constant = -fromVC.view.bounds.size.height
                        fromVC.view.layoutIfNeeded()
                    }, completion: { (completed) in
                        fromVC.view.removeFromSuperview()
                        transitionContext.completeTransition(completed)
                    })
                }
            }
        }
    }
}

class QTBaseCustomDialog: UIViewController {
    
    @IBOutlet weak var constraintContentViewBottom: NSLayoutConstraint?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        transitioningDelegate = self
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        transitioningDelegate = self
        modalPresentationStyle = .overCurrentContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapView(_:)))
        view.subviews.first?.addGestureRecognizer(tap)
    }
    
    @objc
    private func onTapView(_ guesture: UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension QTBaseCustomDialog: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = CustomDialogAnimator()
        animator.animationStyle = .presenting
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = CustomDialogAnimator()
        animator.animationStyle = .dismissing
        
        return animator
    }
}
