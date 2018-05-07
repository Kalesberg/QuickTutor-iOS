//
//  ImageCropper.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit

class ViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
	
	let picker = UIImagePickerController()
	
	var circlePath = UIBezierPath()
	var imageView: UIImageView!
	
	var scroll: UIScrollView! {
		didSet {
			scroll.delegate = self
			scroll.minimumZoomScale = 1.0
			scroll.maximumZoomScale = 10.0
			scroll.zoomScale = 1.0
		}
	}
	
	//MARK: -View Methods
	
	override func viewDidLoad()
	{
		super.viewDidLoad()

		picker.delegate = self
		let size : CGFloat = 200
		layer(x: (self.view.frame.size.width / 2) - (size/2), y: (self.view.frame.size.height / 2) - (size / 2), width: size,height: size,cornerRadius: 0)
	}
	
	//MARK: -SubLayer
	
	func layer(x: CGFloat,y: CGFloat,width: CGFloat,height: CGFloat,cornerRadius: CGFloat)
	{
		let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), cornerRadius: 0)
		circlePath = UIBezierPath(roundedRect: CGRect(x: x,y: y,width: width,height: height), cornerRadius: cornerRadius)
		path.append(circlePath)
		path.usesEvenOddFillRule = true
		let fillLayer = CAShapeLayer()
		fillLayer.path = path.cgPath
		fillLayer.fillRule = kCAFillRuleEvenOdd
		fillLayer.opacity = 0.7
		fillLayer.fillColor = UIColor.lightGray.cgColor
		view.layer.addSublayer(fillLayer)
	}
	
	//MARK: -UIScrollViewDelegate
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	
	//MARK: -Cropping
	
	func cropping(_ sender: UIBarButtonItem) {
		let croppedCGImage = imageView.image?.cgImage?.cropping(to: cropArea)
		self.present(controller, animated: true, completion: nil)
		controller.photo.image = croppedImage
	}
	
	var cropArea:CGRect
	{
		get{
			let factor = imageView.image!.size.width/view.frame.width
			let scale = 1/scroll.zoomScale
			let imageFrame = imageView.imageFrame()
			let x = (scroll.contentOffset.x + circlePath.bounds.origin.x - imageFrame.origin.x) * scale * factor
			let y = (scroll.contentOffset.y + circlePath.bounds.origin.y - imageFrame.origin.y) * scale * factor
			let width =  circlePath.bounds.width  * scale * factor
			let height = circlePath.bounds.height  * scale * factor
			return CGRect(x: x, y: y, width: width, height: height)
		}
		
	}
	
	//MARK: -UIImagePickerControllerDelegate
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
	{
		let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
		imageView.contentMode = .scaleAspectFit
		imageView.image = chosenImage.resizeImage(image: chosenImage, targetSize: CGSize(width: 3024 , height: 4032))
		dismiss(animated:true, completion: nil)
	}
	
	//MARK: -ShootImage
	
}
