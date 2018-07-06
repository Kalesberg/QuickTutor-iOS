//
//  TutorProfileImageView.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

protocol AWImageViewer {
	func dismiss()
}


class TutorProfileImageView : InteractableView, Interactable {
	
	required init() {
		fatalError("init() has not been implemented")
	}
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	init(images: [String: String]) {
		super.init()
		pageCount = images.count
		pageControl.numberOfPages = pageCount
		setupImages(images: images)
		
	}
	
	let horizontalScrollView : UIScrollView = {
		let scrollView = UIScrollView()
		
		scrollView.isUserInteractionEnabled = true
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		
		return scrollView
	}()
	
	let pageControl : UIPageControl = {
		let pageControl = UIPageControl()
		
		pageControl.currentPage = 0
		pageControl.pageIndicatorTintColor = .white
		pageControl.currentPageIndicatorTintColor = Colors.learnerPurple
		
		return pageControl
	}()
	var pageCount : Int!
	
	var delegate : AWImageViewer?
	
	override func configureView() {
		addSubview(horizontalScrollView)
		addSubview(pageControl)
		super.configureView()
		alpha = 0.0
		pageControl.addTarget(self, action: #selector(changePage(_:)), for: UIControlEvents.valueChanged)
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapScrollView(_:)))
		tapRecognizer.numberOfTapsRequired = 1
		tapRecognizer.isEnabled = true
		tapRecognizer.cancelsTouchesInView = false
		horizontalScrollView.addGestureRecognizer(tapRecognizer)
		
		horizontalScrollView.delegate = self
		backgroundColor = UIColor.black.withAlphaComponent(0.5)
		applyConstraints()
	}
	override func applyConstraints() {
		horizontalScrollView.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(0.7)
			make.height.equalToSuperview().multipliedBy(0.35)
		}
		pageControl.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalTo(horizontalScrollView.snp.bottom).inset(-10)
			make.width.equalToSuperview()
		}
	}
	override func layoutSubviews() {
		self.horizontalScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(pageCount),height: horizontalScrollView.frame.size.height)
	}
	@objc private func didTapScrollView(_ sender: UITapGestureRecognizer) {
		delegate?.dismiss()
	}
	private func setupImages(images: [String : String]) {
		var count = 1
		for key in images.keys.sorted(by: (<)) {

			let imageView = UIImageView()
			imageView.loadUserImages(by: images[key]!)
			imageView.scaleImage()
			self.horizontalScrollView.addSubview(imageView)

			imageView.snp.makeConstraints({ (make) in
				make.top.equalToSuperview()
				make.height.equalToSuperview()
				make.width.equalTo(UIScreen.main.bounds.width)
				if (count != 1) {
					make.left.equalTo(self.horizontalScrollView.subviews[count - 2].snp.right)
				} else {
					make.centerX.equalToSuperview()
				}
			})
			count += 1
		}
		layoutIfNeeded()
	}
	@objc private func changePage(_ sender: AnyObject) {
		let x = CGFloat(pageControl.currentPage) * horizontalScrollView.frame.size.width
		horizontalScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
	}
	func touchStart() {
		delegate?.dismiss()
	}
}
extension TutorProfileImageView : UIScrollViewDelegate {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageNumber = round(horizontalScrollView.contentOffset.x / horizontalScrollView.frame.size.width)
		pageControl.currentPage = Int(pageNumber)
	}
}
extension UIViewController {
	func displayAWImageViewer(images: [String : String]) {
		if let _ = self.view.viewWithTag(2)  {
			return
		}
		let imageViewer = TutorProfileImageView(images: images)
		imageViewer.tag = 2
		imageViewer.frame = self.view.bounds
		imageViewer.delegate = self as? AWImageViewer

		UIView.animate(withDuration: 0.2, animations: {
			imageViewer.alpha = 1.0
			imageViewer.transform = .identity
		})
		self.view.addSubview(imageViewer)
	}
	
	func dismissAWImageViewer() {
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
