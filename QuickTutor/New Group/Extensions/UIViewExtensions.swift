//
//  UIViewExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func applyGradient(firstColor: CGColor, secondColor: CGColor, angle: Double, frame: CGRect, cornerRadius: CGFloat = 0, locations: [NSNumber] = [0, 0.7, 0.9, 1]) {
        let firstColor = firstColor
        let secondColor = secondColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = [ firstColor, secondColor ]
        
        let x: Double! = angle / 360.0
        let a = pow(sinf(Float(2.0 * .pi * ((x + 0.75) / 2.0))),2.0);
        let b = pow(sinf(Float(2 * .pi * ((x+0.0)/2))),2);
        let c = pow(sinf(Float(2 * .pi * ((x+0.25)/2))),2);
        let d = pow(sinf(Float(2 * .pi * ((x+0.5)/2))),2);
        
        gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
        gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.locations = locations
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func createParagraphAttribute() -> NSParagraphStyle {
        var paragraphStyle: NSMutableParagraphStyle
        paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 18, options: NSDictionary() as! [NSTextTab.OptionKey : Any])]
        paragraphStyle.defaultTabInterval = 18
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 18
        
        return paragraphStyle
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.7
        animation.values = [-5, 5, -2.5, 2.5, -1, 1]
        layer.add(animation, forKey: "shake")
    }
    
    func fadeIn(withDuration duration: TimeInterval, alpha: CGFloat) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        })
    }
    
    func fadeOut(withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
    
    func slideInFromLeft(duration: TimeInterval = 0.3, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromLeftTransition.delegate = (delegate as! CAAnimationDelegate)
        }
        
        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    
    func slideInFromRight(duration: TimeInterval = 0.3, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromRightTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromRightTransition.delegate = (delegate as! CAAnimationDelegate)
        }
        
        // Customize the animation's properties
        slideInFromRightTransition.type = CATransitionType.push
        slideInFromRightTransition.subtype = CATransitionSubtype.fromRight
        slideInFromRightTransition.duration = duration
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromRightTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromRightTransition, forKey: "slideInFromRightTransition")
    }
    func fadeTransition(_ duration : CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: convertFromCATransitionType(CATransitionType.fade))
    }
    
    func cornerRadius(_ corners: UIRectCorner = .allCorners, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            if corners.contains(.allCorners) {
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMinYCorner]
            } else {
                layer.maskedCorners = []
                if corners.contains(.topLeft) {
                    layer.maskedCorners = layer.maskedCorners.union(.layerMinXMinYCorner)
                }
                if corners.contains(.topRight) {
                    layer.maskedCorners = layer.maskedCorners.union(.layerMaxXMinYCorner)
                }
                if corners.contains(.bottomLeft) {
                    layer.maskedCorners = layer.maskedCorners.union(.layerMinXMaxYCorner)
                }
                if corners.contains(.bottomRight) {
                    layer.maskedCorners = layer.maskedCorners.union(.layerMaxXMaxYCorner)
                }
            }
            layer.cornerRadius = radius
        } else {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
	
	func growShrink() {
		UIView.animate(withDuration: 0.1, animations: {
			self.alpha = 1.0
			self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
		}) { (finished) in
			UIView.animate(withDuration: 0.2, animations: {
				self.transform = CGAffineTransform.identity
			})
		}
	}
	func growSemiShrink(_ completion: @escaping () -> ()) {
		UIView.animate(withDuration: 0.1, animations: {
			self.alpha = 1.0
			self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		}) { (finished) in
			UIView.animate(withDuration: 0.2, animations: {
				self.transform = CGAffineTransform.identity
			}) { (finished) in
				completion()
			}
		}
	}
	
	func shrink() {
		UIView.animate(withDuration: 0.2, animations: {
			self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		})
	}
	func applySettingsShadow() {
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOffset = CGSize(width: 0, height: -1)
		self.layer.shadowRadius = 6
		self.layer.shadowOpacity = 0.3
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATransitionType(_ input: CATransitionType) -> String {
	return input.rawValue
}
