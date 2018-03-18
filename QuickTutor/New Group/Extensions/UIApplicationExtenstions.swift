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
}
