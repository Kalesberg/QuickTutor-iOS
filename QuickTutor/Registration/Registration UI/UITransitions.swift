//
//  UITransitions.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/29/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class Transition {
	
	let transition = CATransition()
	transition.duration = 0.4
	transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
	transition.type = kCATransitionPu
}
