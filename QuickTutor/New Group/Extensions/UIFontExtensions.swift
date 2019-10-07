//
//  UIFontExtensions.swift
//  QuickTutor
//
//  Created by Michael Burkard on 1/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

extension UIFont {
    class func qtHeavyFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Heavy", size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
    }
    
    class func qtBoldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    class func qtBlackFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Black", size: size) ?? UIFont.systemFont(ofSize: size, weight: .black)
    }
    
    class func qtSemiBoldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Semibold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    class func qtMediumFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
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
