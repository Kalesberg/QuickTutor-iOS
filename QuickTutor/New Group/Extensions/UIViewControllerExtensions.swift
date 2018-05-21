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
			if controller is LearnerPageViewController {
				self.popToViewController(controller, animated: false)
				break
			} else {
				print("unable to pop!")
			}
		}
	}
    
    func popBackToMainAnimated() {
        for controller in self.viewControllers {
            if controller is MessagesVC {
                self.popToViewController(controller, animated: true)
                break
            } else {
                print("unable to pop!")
            }
        }
    }
    
	func popBackToMainWithAddTutor(){
		for controller in self.viewControllers {
			if controller is LearnerPageViewController {
				popViewControllerWithHandler {
					self.pushViewController(MessagesVC(), animated: true)
				}
				break
			}
		}
	}
	func popBackToTutorMain() {
		for controller in self.viewControllers {
			if controller is TutorPageViewController {
				self.popToViewController(controller, animated: true)
				break
			}
		}
	}
	func popViewControllerWithHandler(completion: @escaping ()->()) {

		CATransaction.begin()
		CATransaction.setCompletionBlock(completion)
		
		let nav = self
		let transition = CATransition()
		
		nav.view.layer.add(transition.popFromTop(), forKey: nil)
		nav.popViewController(animated: true)
		
		CATransaction.commit()
	}
	func popThenPopThenPopTHenPushSon() {
		popViewControllerWithHandler {
			
		}
		self.popViewControllerWithHandler {
			self.pushViewController(MessagesVC(), animated: true)
		}
	}
}

extension UIPageViewController {
	func goToNextPage(){
		guard let currentViewController = self.viewControllers?.first else { return }
		guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
		setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
	}
    
    func gotToPreviousPage() {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else { return }
        setViewControllers([previousViewController], direction: .reverse, animated: true, completion: nil)
    }
}
