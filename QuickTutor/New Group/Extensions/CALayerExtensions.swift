//
//  CGLayerExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    func applyShadow(color: CGColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        shadowColor = color
        shadowOpacity = opacity
        shadowOffset = offset
        shadowRadius = radius
        masksToBounds = false
    }
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
}
