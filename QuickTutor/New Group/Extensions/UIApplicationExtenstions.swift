//
//  UIApplicationExtenstions.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

extension UIApplication {
	class func getPresentedViewController() -> UIViewController? {
		var presentViewController = UIApplication.shared.keyWindow?.rootViewController
		while let pVC = presentViewController?.presentedViewController
		{
			presentViewController = pVC
		}
		return presentViewController
	}
    
    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
#if __LP64__
            let tag = 38482458385
            if let statusBar = UIApplication.shared.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let statusBar = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBar.tag = tag
                UIApplication.shared.keyWindow?.addSubview(statusBar)
                return statusBar
            }
#else
            let tag = 38482458
            let statusBar = UIView(frame: UIApplication.shared.statusBarFrame)
            statusBar.tag = tag
            UIApplication.shared.keyWindow?.addSubview(statusBar)
            return statusBar
#endif
        } else {
            return UIApplication.shared.value(forKey: "statusBar") as? UIView
        }
    }
}
