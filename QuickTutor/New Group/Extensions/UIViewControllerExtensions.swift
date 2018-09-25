//
//  ViewControllerExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Lottie

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
        
		let loadingView : LOTAnimationView = LOTAnimationView(name: "loading12")
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = self.view.center
        loadingView.contentMode = .scaleAspectFill
        loadingView.loopAnimation = true
        loadingView.tag = 69
        loadingView.animationSpeed = 0.75
        
        view.addSubview(loadingView)
        
        loadingView.play()
	}
	
	func dismissOverlay() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
       // self.view.endEditing(true)
		if let loadingAnimationView = self.view.viewWithTag(69) as? LOTAnimationView {
			loadingAnimationView.stop()
			loadingAnimationView.removeFromSuperview()
		} else {
			print("Could not find view")
		}
	}
	
	func displayProfileImageViewer(imageCount: Int, userId: String) {
		if let _ = self.view.viewWithTag(22)  {
			return
		}
		let imageViewer = ProfileImageViewer(imageCount: imageCount, userId: userId)
		imageViewer.tag = 2
		imageViewer.frame = self.view.bounds
		imageViewer.delegate = self as? ProfileImageViewerDelegate
		
		UIView.animate(withDuration: 0.2, animations: {
			imageViewer.alpha = 1.0
			imageViewer.transform = .identity
		})
		self.view.addSubview(imageViewer)
	}
	
	func dismissProfileImageViewer() {
		self.view.endEditing(true)
		if let imageViewer = self.view.viewWithTag(2) {
			UIView.animate(withDuration: 0.2, animations: {
				imageViewer.alpha = 0.0
				imageViewer.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
			}) { _ in
				imageViewer.removeFromSuperview()
			}
		}
	}
}

extension UINavigationController {
	
	func popBackToMain() {
		for controller in self.viewControllers {
			if AccountService.shared.currentUserType == .learner {
				if controller is LearnerPageVC {
					self.popToViewController(controller, animated: true)
				}
			} else {
				if controller is TutorPageViewController {
					self.popToViewController(controller, animated: true)
					break
				}
			}
		}
	}
	func popBackToAddTutor() {
		for controller in self.viewControllers {
			if controller is AddTutorVC {
				self.popToViewController(controller, animated: false)
				break
			}
		}
	}
	func popBackToTutorConnect() {
		for controller in self.viewControllers {
			if controller is TutorConnectVC {
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
			if controller is SearchSubjectsVC {
				self.popToViewController(controller, animated: true)
				return
			}
		}
		pushViewController(SearchSubjectsVC(), animated: true)
	}
	
	func popBackToMainWithAddTutor(){
		for controller in self.viewControllers {
			if controller is LearnerPageVC {
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
