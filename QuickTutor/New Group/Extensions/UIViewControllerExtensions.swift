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
    
    class LoadingScreen : InteractableView {
        
        let bigSquare : UIView = {
            let view = UIView()
            
            view.backgroundColor = Colors.darkBackground
            view.layer.cornerRadius = 8
            view.layer.borderWidth = 2
            
            if AccountService.shared.currentUserType == .learner {
                view.layer.borderColor = Colors.learnerPurple.cgColor
            } else {
                view.layer.borderColor = Colors.tutorBlue.cgColor
            }
            
            
            return view
        }()
        
        let smallSquare : UIView = {
            let view = UIView()
            
            view.backgroundColor = .clear
            
            return view
        }()
        
        let dot1 : UIView = {
            let view = UIView()
            view.backgroundColor = Colors.brightGreen
            view.layer.cornerRadius = 10
            return view
        }()
        
        let dot2 : UIView = {
            let view = UIView()
            
            view.backgroundColor = .gray
            view.layer.cornerRadius = 10
            return view
        }()
        
        let dot3 : UIView = {
            let view = UIView()
            view.backgroundColor = .gray
            view.layer.cornerRadius = 10
            return view
        }()
        
        let dot4 : UIView = {
            let view = UIView()
            view.backgroundColor = .gray
            view.layer.cornerRadius = 10
            return view
        }()
        
        override func configureView() {
            addSubview(bigSquare)
            bigSquare.addSubview(smallSquare)
            smallSquare.addSubview(dot1)
            smallSquare.addSubview(dot2)
            smallSquare.addSubview(dot3)
            smallSquare.addSubview(dot4)
            super.configureView()
            
            backgroundColor = UIColor.black.withAlphaComponent(0.3)
            transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            alpha = 0.0
            
            applyConstraints()
        }
        
        override func applyConstraints() {
            bigSquare.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.height.width.equalTo(120)
            }
            
            smallSquare.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.height.width.equalTo(70)
            }
            
            dot1.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.height.width.equalTo(20)
            }
            dot2.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.right.equalToSuperview()
                make.height.width.equalTo(20)
            }
            dot3.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.height.width.equalTo(20)
            }
            dot4.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.right.equalToSuperview()
                make.height.width.equalTo(20)
            }
        }
    }
    
	func displayLoadingOverlay() {

		if let _ = self.view.viewWithTag(69)  {
			return
		}
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		let overlay = LoadingScreen()
		overlay.tag = 69
        overlay.frame = self.view.bounds
		
        UIView.animate(withDuration: 0.2, animations: {
            overlay.alpha = 1.0
            overlay.transform = .identity
        }, completion: { (true) in
            UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [.repeat, .calculationModeLinear], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.375, animations: {
                    overlay.dot2.backgroundColor = Colors.yellow
                    overlay.dot1.backgroundColor = .gray
                })
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.375, animations: {
                    overlay.dot4.backgroundColor = Colors.qtRed
                    overlay.dot2.backgroundColor = .gray
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.375, animations: {
                    if AccountService.shared.currentUserType == .learner {
                        overlay.dot3.backgroundColor = Colors.tutorBlue
                    } else {
                        overlay.dot3.backgroundColor = Colors.learnerPurple
                    }
                    
                    overlay.dot4.backgroundColor = .gray
                })
                UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.375, animations: {
                    overlay.dot1.backgroundColor = Colors.green
                    overlay.dot3.backgroundColor = .gray
                })
            }, completion: nil )
        })
		self.view.addSubview(overlay)
	}
	func dismissOverlay() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if let overlay = self.view.viewWithTag(69)  {
            UIView.animate(withDuration: 0.2, animations: {
                overlay.alpha = 0.0
                overlay.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            }) { _ in
                overlay.removeFromSuperview()
            }
        }
	}
}

extension UINavigationController {
	
	func popBackToMain() {
		for controller in self.viewControllers {
			if controller is LearnerPageViewController {
				self.popToViewController(controller, animated: false)
				break
			}
		}
	}
	
	func popBackToTutorConnect() {
		for controller in self.viewControllers {
			if controller is TutorConnect {
				self.popToViewController(controller, animated: false)
				break
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
	
	func popOrPushSearchSubjects() {
		for controller in self.viewControllers {
			if controller is SearchSubjects {
				self.popToViewController(controller, animated: true)
				return
			}
		}
		pushViewController(SearchSubjects(), animated: true)
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
