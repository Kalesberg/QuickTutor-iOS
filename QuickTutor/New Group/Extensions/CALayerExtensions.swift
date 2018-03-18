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
}
