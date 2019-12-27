//
//  QTHookModelNavigationController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/6/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class FadeAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let presenting: Bool
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let container = transitionContext.containerView
        if presenting {
            container.addSubview(toView)
            toView.alpha = 0.0
        } else {
            container.insertSubview(toView, belowSubview: fromView)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            if self.presenting {
                toView.alpha = 1.0
            } else {
                fromView.alpha = 0.0
            }
        }, completion: { _ in
            let success = !transitionContext.transitionWasCancelled
            if !success {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(success)
        })
    }
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
}

protocol QTHookModelNavigationControllerDelegate {
    func didFinishHookModel(_ viewController: UIViewController)
}

class QTHookModelNavigationController: SwipeNavigationController {

    var hookModelDelegate: QTHookModelNavigationControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate = self
        
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(color: .clear), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = Colors.purple
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideTabBar(hidden: true)
    }

}

extension QTHookModelNavigationController {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if .push == operation {
            return FadeAnimationController(presenting: true)
        } else {
            return FadeAnimationController(presenting: false)
        }
    }
}
