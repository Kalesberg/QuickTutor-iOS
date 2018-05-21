//
//  LoadingScreen.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

protocol OverlayViewController : class {
	var overLaySize : CGSize? { get }
	func presentOverlay(from parentViewController: UIViewController)
	func dismissOverLay()
}
extension OverlayViewController where Self : UIViewController {
	var overlaySize : CGSize? {
		return nil
	}
	private var overlayTag : Int {
		return 696969
	}
	
	func presentOverlay(from parentViewCotnroller: UIViewController) {
		let parentBounds = parentViewCotnroller.view.bounds
		
		let overLayView : UIView = {
			let view = UIView()
			view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
			view.frame = parentBounds
			view.alpha = 0.0
			view.isUserInteractionEnabled = true
			view.tag = overlayTag
			return view
		}()
		parentViewCotnroller.view.addSubview(view)
		parentViewCotnroller.addChildViewController(self)
		
	}
}
