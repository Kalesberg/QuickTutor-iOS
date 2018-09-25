//
//  ImageMessageAnimator.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol ImageMessageAnimatorDelegate {
    func imageAnimatorWillZoomIn(_ imageAnimator: ImageMessageAnimator)
    func imageAnimatorDidZoomIn(_ imageAnimator: ImageMessageAnimator)
    func imageAnimatorWillZoomOut(_ imageAnimator: ImageMessageAnimator)
    func imageAnimatorDidZoomOut(_ imageAnimator: ImageMessageAnimator)
}

extension ImageMessageAnimatorDelegate {
    func imageAnimatorWillZoomIn(_: ImageMessageAnimator) {}
    func imageAnimatorDidZoomIn(_: ImageMessageAnimator) {}
    func imageAnimatorWillZoomOut(_: ImageMessageAnimator) {}
    func imageAnimatorDidZoomOut(_: ImageMessageAnimator) {}
}

class ImageMessageAnimator: ImageMessageCellDelegate {
    var parentController: UIViewController!
    var delegate: ImageMessageAnimatorDelegate?

    var imageCellImageView: UIImageView?
    let zoomView = UIImageView()
    let zoomBackground = UIView()

    let navBarCover: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    let inputAccessoryCover: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    func handleZoomFor(imageView: UIImageView) {
        delegate?.imageAnimatorWillZoomIn(self)
        guard let window = UIApplication.shared.keyWindow else { return }
        parentController.resignFirstResponder()
        navBarCover.alpha = 0
        inputAccessoryCover.alpha = 0
        window.addSubview(navBarCover)

        guard let navBarHeight = parentController.navigationController?.navigationBar.frame.height else { return }
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        navBarCover.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: nil, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: navBarHeight + statusBarHeight)

        imageCellImageView = imageView

        zoomBackground.backgroundColor = .black
        zoomBackground.alpha = 0
        zoomBackground.frame = parentController.view.frame
        zoomBackground.isUserInteractionEnabled = true
        zoomBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        parentController.view.addSubview(zoomBackground)

        imageView.alpha = 0
        guard let startingFrame = imageView.superview?.convert(imageView.frame, to: nil) else { return }
        zoomView.image = imageView.image
        zoomView.contentMode = .scaleAspectFill
        zoomView.clipsToBounds = true
        zoomView.backgroundColor = .black
        zoomView.frame = startingFrame
        zoomView.isUserInteractionEnabled = true
        parentController.view.addSubview(zoomView)

        zoomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))

        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            let height = (self.parentController.view.frame.width / startingFrame.width) * startingFrame.height
            let y = self.parentController.view.frame.height / 2 - height / 2
            self.zoomView.frame = CGRect(x: 0, y: y, width: self.parentController.view.frame.width, height: height)
            self.zoomBackground.alpha = 1
            self.navBarCover.alpha = 1
            self.parentController.inputAccessoryView?.alpha = 0
            self.parentController.resignFirstResponder()
            self.delegate?.imageAnimatorDidZoomIn(self)
        }.startAnimation()
    }

    @objc func zoomOut() {
        delegate?.imageAnimatorWillZoomOut(self)
        guard let startingFrame = imageCellImageView!.superview?.convert(imageCellImageView!.frame, to: nil) else { return }

        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.zoomView.frame = startingFrame
            self.zoomBackground.alpha = 0
            self.navBarCover.alpha = 0
            self.parentController.inputAccessoryView?.alpha = 1
        }

        animator.addCompletion { _ in
            self.zoomBackground.removeFromSuperview()
            self.zoomView.removeFromSuperview()
            self.imageCellImageView?.alpha = 1
            self.navBarCover.removeFromSuperview()
            self.parentController.becomeFirstResponder()
        }

        animator.startAnimation()
    }

    init(parentViewController: UIViewController) {
        parentController = parentViewController
    }
}
