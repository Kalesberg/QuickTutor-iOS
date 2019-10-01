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
            let tag = 3848245
            if let statusBar = UIApplication.shared.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let statusBar = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBar.tag = tag
                UIApplication.shared.keyWindow?.addSubview(statusBar)
                return statusBar
            }
        } else {
            return UIApplication.shared.value(forKey: "statusBar") as? UIView
        }
    }
}
