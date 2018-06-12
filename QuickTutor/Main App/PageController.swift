//
//  PageController.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import UIKit
import SnapKit

protocol PageObservation : class {
	func getParentPageViewController(parentRef: PageViewController)
}

class PageViewController : UIPageViewController {
	// all this needs is a navbar that is really a scrollview.
	
	var orderedViewControllers: [UIViewController] = []
	
	override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
		super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureViewControllers()
		configureDelegates()
		configureView()
        
        automaticallyAdjustsScrollViewInsets = false
	}
	
    func configureViewControllers() { }
	
	private func configureDelegates() {
		delegate = self
		//dataSource = self
		
		let scrollView = view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView
		scrollView.delegate = self
		
		if let firstViewController = orderedViewControllers.first {
			setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
		}
        
	}
	private func configureView() {
		self.view.backgroundColor = Colors.backgroundDark
	}
}

class LearnerPageViewController : PageViewController {
    
    override func configureViewControllers() {
		
        let mainPage = LearnerMainPage() as PageObservation
        mainPage.getParentPageViewController(parentRef: self)
		orderedViewControllers.append(mainPage as! UIViewController)
        
        let messaging = MessagesVC()
        messaging.parentPageViewController = self
        orderedViewControllers.append(messaging)
        
    }
    
    @objc func showAddTutor() {
		
		let nav = self.navigationController
		let transition = CATransition()
		
		DispatchQueue.main.async {
			nav?.view.layer.add(transition.segueFromBottom(), forKey: nil)
			nav?.pushViewController(AddTutorVC(), animated: false)
		}
    }
    
    @objc func popVC() {
		let nav = self.navigationController
		let transition = CATransition()
		DispatchQueue.main.async {
			nav?.view.layer.add(transition.popFromTop(), forKey: nil)
			nav?.popViewController(animated: false)
		}
    }
}

class TutorPageViewController : PageViewController {
    
    override func configureViewControllers() {
        let mainPage = TutorMainPage() as PageObservation
        mainPage.getParentPageViewController(parentRef: self)
        orderedViewControllers.append(mainPage as! UIViewController)
        
        let messaging = MessagesVC()
        messaging.parentPageViewController = self
        orderedViewControllers.append(messaging)
    }
}

extension PageViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate {

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		//get current index.
		guard let index = orderedViewControllers.index(of: viewController) else { return nil }
		
		let previous = index - 1
		//check to make sure we have previous index.
		guard previous >= 0 else { return nil }
		
		guard orderedViewControllers.count > previous else { return nil }
		
		return orderedViewControllers[previous]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let index = orderedViewControllers.index(of: viewController) else { return nil }
		let next = index + 1
		let count = orderedViewControllers.count
		
		guard count != next else { return nil }
		guard count > next else { return nil }
		
		return orderedViewControllers[next]
	}
}
extension PageViewController : UIScrollViewDelegate {

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
	
	}
}
