//
//  AACircleCropCutterView.swift
//
//  Created by Keke Arif on 21/02/2016.
//  Modified by Andrea Antonioni on 14/01/2017
//  Copyright © 2017 Andrea Antonioni. All rights reserved.
//

import UIKit

class AACircleCropCutterView: UIView {
    
    /// Diameter of the circle
    var circleDiameter: CGFloat = 240 {
        didSet {
            setNeedsDisplay()
        }
    }
	var isListing : Bool = false
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isOpaque = false
    }

    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7).setFill()
        UIRectFill(rect)
        
		
		
		if isListing {
			// Draw a rectangle around the circle, just to see the effective cutted image
			let square = UIBezierPath(rect: CGRect(x: rect.size.width/2 - circleDiameter/2, y: rect.size.height/2 - circleDiameter/2, width: circleDiameter, height: circleDiameter))
			UIColor.lightGray.setStroke()
			square.lineWidth = 1.0
			context?.setBlendMode(.clear)
			UIColor.clear.setFill()
			square.fill()
			square.stroke()
		} else {
            let roundedSquare = UIBezierPath(roundedRect: CGRect(x: rect.size.width/2 - circleDiameter/2, y: rect.size.height/2 - circleDiameter/2, width: circleDiameter, height: circleDiameter), cornerRadius: 8)
            UIColor.lightGray.setStroke()
            roundedSquare.lineWidth = 1.0
            context?.setBlendMode(.clear)
            UIColor.clear.setFill()
            roundedSquare.fill()
            roundedSquare.stroke()

		}
	}
    
    // Allow touches through the circle crop cutter view
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
    
}
