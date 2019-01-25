//
//  SavedTutorsVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class SavedTutorsVC: UIViewController {
    
    var datasource = [AWTutor]()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        cv.register(TutorCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.darkBackground
        navigationItem.title = "Saved"
        navigationController?.navigationBar.barTintColor = Colors.newBackground
        navigationController?.navigationBar.backgroundColor = Colors.newBackground
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
    
    func loadSavedTutors() {
        
    }
}

protocol TutorDataSource {
    var tutor: AWTutor? { get set }
}

class LearnerMainPageAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let originFrame: CGRect
    
    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        let toView = toViewController.view!
        let finalFrame = toView.frame
        transitionContext.containerView.addSubview(toView)
        toView.frame = originFrame
        toView.alpha = 0
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toView.alpha = 1
            toView.frame = finalFrame
            toView.layoutIfNeeded()
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
}
