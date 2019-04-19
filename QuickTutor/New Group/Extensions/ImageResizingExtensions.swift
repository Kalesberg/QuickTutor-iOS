//
//  ImageResizingExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

extension UIImage {
	var isPortrait:  Bool    { return size.height > size.width }
	var isLandscape: Bool    { return size.width > size.height }
	var breadth:     CGFloat { return min(size.width, size.height) }
	var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
	var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
	
	var circleMasked: UIImage? {
		UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
		defer { UIGraphicsEndImageContext() }
		guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
		UIBezierPath(ovalIn: breadthRect).addClip()
		UIImage(cgImage: cgImage, scale: 1.0, orientation: imageOrientation).draw(in: breadthRect)
		return UIGraphicsGetImageFromCurrentImageContext()
	}
	
	func resizeImage(targetSize: CGSize) -> UIImage {
		let size = self.size
		let widthRatio  = targetSize.width  / self.size.width
		let heightRatio = targetSize.height / self.size.height
		var newSize: CGSize
		
		if (widthRatio > heightRatio) {
			newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
		} else {
			newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
		}
		
		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		self.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage!
	}
	
	convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		color.setFill()
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		guard let cgImage = image?.cgImage else { return nil }
		self.init(cgImage: cgImage)
	}
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
    func alpha(_ value: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
