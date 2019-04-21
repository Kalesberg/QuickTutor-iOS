//
//  ViewControllerExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Lottie
import Firebase

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
                view.layer.borderColor = Colors.purple.cgColor
            } else {
                view.layer.borderColor = Colors.purple.cgColor
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
        
		let loadingView : LOTAnimationView = LOTAnimationView(name: "loadingNew")
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        loadingView.center = self.view.center
        loadingView.contentMode = .scaleAspectFill
        loadingView.loopAnimation = true
        loadingView.tag = 69
        loadingView.animationSpeed = 1
        
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
    
    func showRatingViewControllerForSession(_ session: Session?, sessionId: String?, cost: Double, partnerId: String, runTime: Int, subject: String) {
        guard let session = session, let sessionId = sessionId else {
            return
        }
        
        let vc = QTRatingReviewViewController.controller
        vc.session = session
        vc.sessionId = sessionId
        vc.costOfSession = cost
        vc.partnerId = partnerId
        vc.runTime = runTime
        vc.subject = subject
        Database.database().reference().child("sessions").child(sessionId).child("cost").setValue(cost)
        Database.database().reference().child("sessions").child(sessionId).updateChildValues(["endedAt": Date().timeIntervalSince1970])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func calculateCostOfSession(price: Double, runtime: Int) -> Double {
        let minimumSessionPrice = 5.0
        let cost = calculatePricePerSecond(price: price, runtime: runtime)
        return cost >= minimumSessionPrice ? cost : minimumSessionPrice
    }
    
    func calculatePricePerSecond(price: Double, runtime: Int) -> Double {
        let p = (price / 60.0) / 60.0 * Double(runtime)
        return round(p * 1000.0) / 1000.0
    }
}

extension UINavigationController {
	
	func popBackToMain() {
		for controller in self.viewControllers {
			if AccountService.shared.currentUserType == .learner {
				if controller is LearnerMainPageVC {
					self.popToViewController(controller, animated: true)
				}
			} else {
				if controller is QTTutorDashboardViewController {
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
			if controller is QuickSearchVC {
				self.popToViewController(controller, animated: true)
				return
			}
		}
		pushViewController(QuickSearchVC(), animated: true)
	}
	
	func popBackToMainWithAddTutor(){
		for controller in self.viewControllers {
			if controller is LearnerMainPageVC {
				popViewControllerWithHandler {
					self.pushViewController(MessagesVC(), animated: true)
				}
				break
			}
		}
	}
	func popBackToTutorMain() {
		for controller in self.viewControllers {
			if controller is QTTutorDashboardViewController {
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
