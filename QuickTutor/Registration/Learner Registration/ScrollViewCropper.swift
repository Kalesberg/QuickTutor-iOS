////
////  ScrollViewCropper.swift
////  QuickTutor
////
////  Created by QuickTutor on 1/12/18.
////  Copyright © 2018 QuickTutor. All rights reserved.
////
//
//import UIKit
//import SnapKit
//
//
//class ImageCropperView : BaseLayoutView {
//	
//	var scrollView	  = UIScrollView()
//	var imageView	  = UIImageView()
//	var doneButton	  = DoneButton()
//	var cancelButton  = CancelButton()
//	
//	var imageViewWidth : NSLayoutConstraint!
//	var imageViewheight : NSLayoutConstraint!
//	
//	var lastZoomScale : CGFloat = 1.0
//	
//	override func configureView() {
//		super.configureView()
//		
//		scrollView.delegate = self
//		scrollView.contentMode = .scaleAspectFit
//		scrollView.autoresizingMask = .flexibleWidth
//		scrollView.showsVerticalScrollIndicator = false
//		scrollView.showsHorizontalScrollIndicator = false
//		scrollView.isUserInteractionEnabled = true
//		scrollView.alwaysBounceHorizontal = true
//		scrollView.alwaysBounceVertical = true
//		
//		imageView.contentMode = .scaleAspectFit
//		imageView.clipsToBounds = true
//
//		scrollView.addSubview(imageView)
//		addSubview(scrollView)
//		addSubview(doneButton)
//		addSubview(cancelButton)
//		
//		applyConstraints()
//	}
//    
//	override func applyConstraints() {
//		super.applyConstraints()
//		
//		scrollView.snp.makeConstraints { (make) in
//			make.width.equalToSuperview()
//			make.height.equalToSuperview().multipliedBy(0.5)
//			make.centerY.equalToSuperview()
//			make.centerX.equalToSuperview()
//		}
//		imageView.snp.makeConstraints { (make) in
//			make.width.equalToSuperview()
//			make.height.equalToSuperview
//			make.centerY.equalToSuperview()
//			make.centerX.equalToSuperview()
//		}
//		doneButton.snp.makeConstraints { (make) in
//			make.bottom.equalToSuperview().dividedBy(1.1)
//			make.width.equalToSuperview().multipliedBy(0.4)
//			make.right.equalToSuperview()
//			make.height.equalToSuperview().multipliedBy(0.1)
//		}
//		cancelButton.snp.makeConstraints { (make) in
//			make.bottom.equalToSuperview().dividedBy(1.1)
//			make.width.equalToSuperview().multipliedBy(0.4)
//			make.left.equalToSuperview()
//			make.height.equalToSuperview().multipliedBy(0.1)
//		}
//	}
//	
//	public func setImageToCrop(image: UIImage) {
//		imageView.image = image
//		imageView.frame.size.width = image.size.width
//		imageView.frame.size.height = image.size.height
//		
//		let scaleWidth = scrollView.frame.size.width / image.size.width
//		let scaleHeight = scrollView.frame.size.width / image.size.height
//		let maxScale = max(scaleWidth, scaleHeight)
//		
//		scrollView.minimumZoomScale = maxScale
//		scrollView.zoomScale = maxScale
//	}
//	
//	fileprivate func centerImageView() {
//		let boundSize : CGSize = scrollView.bounds.size
//		var frameToCenter = imageView.frame
//		if frameToCenter.size.width < boundSize.width {
//			frameToCenter.origin.x = boundSize.width - frameToCenter.size.width / 2
//		} else{
//			frameToCenter.origin.x = 0
//		}
//		if frameToCenter.size.height < boundSize.height {
//			frameToCenter.origin.y = boundSize.height - frameToCenter.size.height / 2
//		}else{
//			frameToCenter.origin.y = 0
//		}
//		imageView.frame = frameToCenter
//	}
//	
//	fileprivate func setZoomScale() {
//		
//		let imageViewSize = imageView.bounds.size
//		let scrollViewSize = scrollView.bounds.size
//		let widthScale = scrollViewSize.width / imageViewSize.width
//		let heightScale = scrollViewSize.height / imageViewSize.height
//		
//		scrollView.minimumZoomScale = min(widthScale, heightScale)
//		scrollView.maximumZoomScale = 4.0
//		scrollView.zoomScale = 1.0
//	}
//	fileprivate func updateZoom() {
//		if let image = imageView.image {
//			var minZoom  = min(scrollView.bounds.size.width / image.size.width,
//							   scrollView.bounds.size.height / image.size.height)
//			
//			if minZoom > 1 { minZoom = 1 }
//			
//			scrollView.minimumZoomScale = 0.5 * minZoom
//			
//			if minZoom == lastZoomScale {
//				minZoom += 0.000001
//			}
//			scrollView.zoomScale = minZoom
//			lastZoomScale = minZoom
//		}
//	}
//	
//	fileprivate func updateConstraintsForView() {
//		if let image = imageView.image {
//			let imageWidth = image.size.width
//			let imageHeight = image.size.height
//			
//			let viewWidth = scrollView.bounds.size.width
//			let viewHeight = scrollView.bounds.size.height
//			
//			// center image if it is smaller than the scroll view
//			var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
//			if hPadding < 0 { hPadding = 0 }
//			
//			var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
//			if vPadding < 0 { vPadding = 0 }
//			
//			imageView.snp.remakeConstraints({ (remake) in
//				remake.left.equalTo(hPadding)
//				remake.right.equalTo(hPadding)
//				remake.top.equalTo(vPadding)
//				remake.bottom.equalTo(vPadding)
//			})
//			layoutIfNeeded()
//		}
//	}
//}
//
//
////Interactables
//class CropperButton : BaseView, Interactable {
//    
//    var label = LeftTextLabel()
//    
//    override func configureView() {
//        addSubview(label)
//		
//        label.label.textColor = .white
//		label.label.font = Font(.installed(.LatoRegular), size: .custom(20)).instance
//        
//        applyConstraints()
//    }
//    
//    override func applyConstraints() {
//        label.snp.makeConstraints { (make) in
//            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
//            make.center.equalToSuperview()
//        }
//    }
//}
//
//class DoneButton: CropperButton {
//    override func configureView() {
//        super.configureView()
//        label.label.text = "Done"
//    }
//}
//
//class CancelButton: CropperButton {
//    override func configureView() {
//        super.configureView()
//        label.label.text = "Cancel"
//    }
//}
//
//
//class ImageCropper : BaseViewController {
//	
//	override var contentView: ImageCropperView {
//		return view as! ImageCropperView
//	}
//	
//	override func loadView() {
//		view = ImageCropperView()
//	}
//	
//	let shapeLayer = CAShapeLayer()
//	var circlePath = UIBezierPath()
//	
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		
//		let size : CGFloat = 200
//		layer(x: (self.view.frame.size.width / 2) - (size/2), y: (self.view.frame.size.height / 2) - (size / 2), width: size,height: size,cornerRadius: 0)
//	}
//    
//    override func handleNavigation() {
//		
//		if (touchStartView == contentView.cancelButton) {
//            let next = UploadImage()
//            let image = UIImage(named: "registration-image-placeholder")
//            next.imagePicked = false
//            next.setImage(image: image!)
//            navigationController?.pushViewController(next, animated: true)
//        } else if (touchStartView == contentView.doneButton) {
//			
//			let image = crop()
//            let next = UploadImage()
//			
//			next.imagePicked = true
//            next.setImage(image: image.circleMasked!)
//            next.contentView.info.isHidden = true
//            next.contentView.addImageButton.isHidden = true
//            next.contentView.buttonView.isHidden = false
//
//			navigationController?.pushViewController(next, animated: true)
//        }
//    }
//	
//	override func viewDidLayoutSubviews() {
//		super.viewDidLayoutSubviews()
//		
//		circlePath = UIBezierPath(arcCenter: CGPoint(x: UIScreen.main.bounds.midX,y: UIScreen.main.bounds.midY), radius: 120, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
//
//		shapeLayer.path = circlePath.cgPath
//		shapeLayer.fillColor = UIColor.clear.cgColor
//		shapeLayer.strokeColor = UIColor.white.cgColor
//		shapeLayer.lineWidth = 2.0
//		
//		contentView.layer.addSublayer(shapeLayer)
//		
//		contentView.setZoomScale()
//		contentView.centerImageView()
//		contentView.updateZoom()
//	}
//	
//	func layer(x: CGFloat,y: CGFloat,width: CGFloat,height: CGFloat,cornerRadius: CGFloat) {
//		
//		let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), cornerRadius: 0)
//		circlePath = UIBezierPath(arcCenter: CGPoint(x: UIScreen.main.bounds.midX,y: UIScreen.main.bounds.midY), radius: 120, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
//		path.append(circlePath)
//		path.usesEvenOddFillRule = true
//		
//		let fillLayer = CAShapeLayer()
//		fillLayer.path = path.cgPath
//		fillLayer.fillRule = kCAFillRuleEvenOdd
//		fillLayer.opacity = 0.7
//		fillLayer.fillColor = UIColor.black.cgColor
//		view.layer.addSublayer(fillLayer)
//	}
//
//	private func crop() -> UIImage {
//
//		let image = contentView.imageView.image!
//
//		let scale : CGFloat = 1 / contentView.scrollView.zoomScale
//		let factor = contentView.imageView.image!.size.width / view.frame.width
//		
//		let x : CGFloat = (contentView.scrollView.contentOffset.x) * scale * factor
//		let y : CGFloat = (contentView.scrollView.contentOffset.y) * scale * factor
//
//		let width : CGFloat = contentView.scrollView.frame.size.width * scale * factor
//		let height : CGFloat = contentView.scrollView.frame.size.height * scale * factor
//
//		let cgImage = image.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height))
//		let croppedImage = UIImage(cgImage: cgImage!, scale: image.scale, orientation: image.imageOrientation)
//
//		return croppedImage
//	}
//}
//
//extension ImageCropperView : UIScrollViewDelegate {
//	
//	func viewForZooming(in scrollView: UIScrollView) -> UIView?{
//		return imageView
//	}
//	
//	func scrollViewDidZoom(_ scrollView: UIScrollView) {
//		updateConstraintsForView()
//	}
//}
//
//
//
