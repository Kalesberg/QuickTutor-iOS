//
//  ImageMessageAnimator.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol ImageMessageAnimatorDelegate: class {
    func imageAnimatorWillZoomIn(_ imageAnimator: ImageMessageAnimator)
    func imageAnimatorDidZoomIn(_ imageAnimator: ImageMessageAnimator)
    func imageAnimatorWillZoomOut(_ imageAnimator: ImageMessageAnimator)
    func imageAnimatorDidZoomOut(_ imageAnimator: ImageMessageAnimator)
}

extension ImageMessageAnimatorDelegate {
    func imageAnimatorWillZoomIn(_ imageAnimator: ImageMessageAnimator) {}
    func imageAnimatorDidZoomIn(_ imageAnimator: ImageMessageAnimator) {}
    func imageAnimatorWillZoomOut(_ imageAnimator: ImageMessageAnimator) {}
    func imageAnimatorDidZoomOut(_ imageAnimator: ImageMessageAnimator) {}
}

class ImageMessageAnimator: ImageMessageCellDelegate {
    
    var parentController: UIViewController!
    weak var delegate: ImageMessageAnimatorDelegate?

    var imageCellImageView: UIImageView?
    let zoomScrollView = UIScrollView()
    let zoomView = UIImageView()
    let zoomBackground = UIView()
    
    let inputAccessoryCover: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    func handleZoomFor(imageView: UIImageView, scrollDelegate: UIScrollViewDelegate, zoomableView: ((UIImageView) -> ())?) {
        delegate?.imageAnimatorWillZoomIn(self)
        parentController.navigationController?.setNavigationBarHidden(true, animated: true)
        parentController.tabBarController?.tabBar.isHidden = true
        
        inputAccessoryCover.alpha = 0
        imageCellImageView = imageView

        zoomBackground.backgroundColor = .black
        zoomBackground.alpha = 0
        zoomBackground.isUserInteractionEnabled = true
        zoomBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        zoomBackground.frame = UIScreen.main.bounds
        parentController.view.addSubview(zoomBackground)
        
        zoomScrollView.delegate = scrollDelegate
        zoomScrollView.frame = UIScreen.main.bounds
        zoomScrollView.alwaysBounceVertical = false
        zoomScrollView.alwaysBounceHorizontal = false
        zoomScrollView.minimumZoomScale = 1.0
        zoomScrollView.maximumZoomScale = 5.0
        zoomScrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        zoomScrollView.isUserInteractionEnabled = true
        zoomScrollView.isPagingEnabled = false
        parentController.view.addSubview(zoomScrollView)
        zoomScrollView.flashScrollIndicators()
        
        imageView.alpha = 0
        guard let startingFrame = imageView.superview?.convert(imageView.frame, to: nil) else { return }
        zoomView.image = imageView.image
        zoomView.contentMode = .scaleAspectFill
        zoomView.clipsToBounds = true
        zoomView.backgroundColor = .black
        zoomView.frame = startingFrame
        zoomView.isUserInteractionEnabled = true
        zoomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        zoomScrollView.addSubview(zoomView)
        
        // Return zoomView to the delegate controller
        if let zoomableView = zoomableView {
            zoomableView(zoomView)
        }

        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            let height = (self.parentController.view.frame.width / startingFrame.width) * startingFrame.height
            let y = self.parentController.view.frame.height / 2 - height / 2
            self.zoomView.frame = CGRect(x: 0, y: y + 50, width: self.parentController.view.frame.width, height: height)
            self.zoomBackground.alpha = 1
            self.parentController.inputAccessoryView?.alpha = 0
            self.delegate?.imageAnimatorDidZoomIn(self)
        }.startAnimation()
    }

    @objc func zoomOut() {
        delegate?.imageAnimatorWillZoomOut(self)
        guard let startingFrame = imageCellImageView!.superview?.convert(imageCellImageView!.frame, to: nil) else { return }

        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.zoomView.frame = startingFrame
            self.zoomBackground.alpha = 0
            self.parentController.inputAccessoryView?.alpha = 1
        }

        animator.addCompletion { _ in
            // Show the bottom tabbar and navigationbar.
            self.parentController.navigationController?.setNavigationBarHidden(false, animated: true)
            self.parentController.tabBarController?.tabBar.isHidden = false
            
            self.zoomBackground.removeFromSuperview()
            self.zoomView.removeFromSuperview()
            self.zoomScrollView.removeFromSuperview()
            
            self.imageCellImageView?.alpha = 1
            self.parentController.becomeFirstResponder()
        }

        animator.startAnimation()
    }

    init(parentViewController: UIViewController) {
        parentController = parentViewController
    }
}
