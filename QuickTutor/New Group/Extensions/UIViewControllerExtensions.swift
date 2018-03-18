//
//  ViewControllerExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func customerServiceAlert(completion: @escaping () -> Void) {
		let alertController = UIAlertController(title: "We Received Your Report!", message: "A QuickTutor customer support team member will be with you shortly.", preferredStyle: .alert)

		let ok = UIAlertAction(title: "Ok thanks!", style: .default) { (alert) in
			completion()
		}
		
		alertController.addAction(ok)
		present(alertController, animated: true, completion: nil)
	}
	func customerServiceYesNoAlert(completion: @escaping () -> Void) {
		let alertController = UIAlertController(title: "We Have Received Your Feeback", message: "Thank you for your feedback. We're sorry for the inconvience", preferredStyle: .alert)
		
		let ok = UIAlertAction(title: "Ok thanks!", style: .default) { (alert) in
			completion()
		}
		alertController.addAction(ok)
		
		present(alertController, animated: true, completion: nil)
	}
}

extension UINavigationController {
	func popBackToMain() {
		for controller in self.viewControllers {
			if controller is PageViewController {
				self.popToViewController(controller, animated: true)
				break
			} else {
				print("unable to pop!")
			}
		}
	}
}

extension UIPageViewController {
	func goToNextPage(){
		guard let currentViewController = self.viewControllers?.first else { return }
		guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
		setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
	}
}
