//
//  UIScrollViewExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

extension UIScrollView {
    func setContentSize() {
        var contentHeight : CGFloat = 0
        
        for view in self.subviews {
            contentHeight += view.frame.size.height
        }
        
        self.contentSize = CGSize(width: 280, height: contentHeight)
    }
}
