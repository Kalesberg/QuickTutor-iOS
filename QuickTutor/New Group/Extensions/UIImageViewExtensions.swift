//
//  UIViewImageExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func scaleImage() {
        autoresizingMask = [.flexibleTopMargin, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth]
        contentMode = UIView.ContentMode.scaleAspectFit
        layer.minificationFilter = CALayerContentsFilter.trilinear
        clipsToBounds = true
    }
}
