//
//  VideoSessionViewManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol VideoSessionPartnerFeedBehaviorDelegate {
    func partnerFeedSwipeDidEnd(_ partnerFeed: UIView)
    func partnerFeedSwipeCancelled(_ parnterFeed: UIView)
}

extension VideoSessionPartnerFeedBehaviorDelegate {
    func partnerFeedSwipeDidEnd(_ partnerFeed: UIView) {}
    func partnerFeedSwipeCancelled(_ parnterFeed: UIView) {}
}

enum CardPosition {
    case topLeft, topRight, bottomLeft, bottomRight
}

class VideoSessionPartnerFeedBehavior: NSObject {
    
    var velocityThreshold: CGFloat = 1000
    var delegate: VideoSessionPartnerFeedBehaviorDelegate?
    var panRecognizer: UIPanGestureRecognizer!
    
    var originalCenter: CGPoint = .zero
    var originalTouch: CGPoint = .zero
    
    var cardPosition = CardPosition.bottomRight
    
    weak var view: UIView! {
        didSet {
            panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(VideoSessionPartnerFeedBehavior.handlePan(_:)))
            view.addGestureRecognizer(panRecognizer)
            view.isUserInteractionEnabled = true
            originalCenter = view.center
        }
    }
    
    func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
        return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate)
    }
    
    func handleProjection(velocity: CGPoint) {
        let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
        let projectionPosition = (
            x: view.frame.midX + project(initialVelocity: velocity.x, decelerationRate: decelerationRate),
            y: view.frame.midY + project(initialVelocity: velocity.y, decelerationRate: decelerationRate)
        )
        
        let point = CGPoint(x: projectionPosition.x, y: projectionPosition.y)
        let nearestCornerPosition = nearestCornerTo(point)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.view.center = nearestCornerPosition
        }, completion: nil)
    }
    
    func nearestCornerTo(_ point: CGPoint) -> CGPoint {
        guard let screenBounds = view.superview?.bounds else {
            return CGPoint(x: self.view.frame.width / 2 + 10, y: self.view.frame.height / 2 + 10)
        }
        
        if point.x <= screenBounds.midX {
            //Should go left
            if point.y <= screenBounds.midY {
                //Should go up
                cardPosition = .topLeft
                return CGPoint(x: self.view.frame.width / 2 + 10, y: self.view.frame.height / 2 + 10)
            } else {
                cardPosition = .bottomLeft
                return CGPoint(x: self.view.frame.width / 2 + 10, y: screenBounds.height - (self.view.frame.height / 2 + 10))
            }
        } else {
            if point.y <= screenBounds.midY {
                cardPosition = .topRight
                return CGPoint(x: screenBounds.width - (self.view.frame.width / 2 + 10), y: self.view.frame.height / 2 + 10)
            } else {
                cardPosition = .bottomRight
                return CGPoint(x: screenBounds.width - (self.view.frame.width / 2 + 10), y: screenBounds.height - (self.view.frame.height / 2 + 10))
            }
        }
        
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let superView = sender.view?.superview, let view = sender.view else { return }
        switch sender.state {
        case .began:
            originalCenter = self.view.center
        case .changed:
            let delta = sender.translation(in: superView)
            view.center = CGPoint(x: originalCenter.x + delta.x, y: originalCenter.y + delta.y)
        case .ended:
            let velocity = sender.velocity(in: superView)
            handleProjection(velocity: velocity)
        default:
            break
        }
        
    }
}
