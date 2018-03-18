//
//  CropImage.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit

class CropImageView : RegistrationGradientView {
	
	var circleCrop = UIImageView()
	var overLay = UIView()
	var panGesture = UIPanGestureRecognizer()
	var pinchGesture = UIPinchGestureRecognizer()
	var originalWidth : CGFloat!
	var originalHeight : CGFloat!
	
	override func configureView() {
		super.configureView()
		addSubview(circleCrop)
		addSubview(overLay)
	
		overLay.alpha = 0.6
		overLay.backgroundColor = .black
		overLay.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
		
		let path = CGMutablePath()
		let radius : CGFloat = 130

		path.addArc(center: CGPoint(x: UIScreen.main.coordinateSpace.bounds.midX, y: UIScreen.main.coordinateSpace.bounds.midY), radius: radius, startAngle: 0.0, endAngle: 2 * 3.14, clockwise: false)
		path.addRect(CGRect(x: 0, y: 0, width: overLay.frame.width, height: overLay.frame.height))
		
		let maskLayer = CAShapeLayer()
		maskLayer.backgroundColor = UIColor.black.cgColor
		maskLayer.path = path;
		maskLayer.fillRule = kCAFillRuleEvenOdd
		
		// Release the path since it's not covered by ARC.
		overLay.layer.mask = maskLayer
		overLay.clipsToBounds = true
		
		pinchGesture.addTarget(self, action: #selector(pinchView))
		panGesture.addTarget(self, action: #selector(panView))
		
		overLay.isUserInteractionEnabled = true
		
		overLay.addGestureRecognizer(pinchGesture)
		overLay.addGestureRecognizer(panGesture)
	
		applyConstraints()
	}
	override func applyConstraints() {
		super.applyConstraints()
		circleCrop.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.95)
			make.height.equalToSuperview().multipliedBy(0.5)
			make.centerY.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
	private func backToCenter(){
		circleCrop.center = overLay.center
	}
	private func backToOriginalSize(){
		print("Fuck")
	}
	
	@objc func pinchView(sender: UIPinchGestureRecognizer) {
		circleCrop.transform = (circleCrop.transform).scaledBy(x: sender.scale, y: sender.scale)
		sender.scale = 1.0
		if circleCrop.frame.width < 250.0 || circleCrop.frame.width > 700.0 {
			pinchGesture.cancel()
			UIView.animate(withDuration: 0.4, animations: {
				self.backToOriginalSize()
			})
		}
	}
	@objc func panView(_ sender: UIPanGestureRecognizer) {
		let translation = sender.translation(in: overLay)
		circleCrop.center = CGPoint(x: circleCrop.center.x + translation.x, y: circleCrop.center.y + translation.y)
		sender.setTranslation(CGPoint.zero, in: overLay)
		print(circleCrop.center)
		
		if circleCrop.center.y < 270 || circleCrop.center.y > 390 {
			panGesture.cancel()
			UIView.animate(withDuration: 0.4, animations: {
				self.backToCenter()
			})
		}
		if circleCrop.center.x < 100 || circleCrop.center.x > 260 {
			panGesture.cancel()
			UIView.animate(withDuration: 0.4, animations: {
				self.backToCenter()
			})
		}
	}
}

class CropImage : UIViewController {
	
	private var contentView: CropImageView {
		return view as! CropImageView
	}
	
	override func loadView() {
		view = CropImageView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		contentView.circleCrop.image = Registration.studentImage
	}
}
extension CropImageView : UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return circleCrop
	}
}
extension UIGestureRecognizer {
	func cancel() {
		isEnabled = false
		isEnabled = true
	}
}
