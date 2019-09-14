//
//  UIFontExtensions.swift
//  QuickTutor
//
//  Created by Michael Burkard on 1/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

extension UIFont {
    class func qtBoldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    class func qtBlackFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Black", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    class func qtSemiBoldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Semibold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    class func qtMediumFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func qtRegularFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func qtBoldItalicFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-BoldItalic", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    class func qtItalicFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Italic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }
}
