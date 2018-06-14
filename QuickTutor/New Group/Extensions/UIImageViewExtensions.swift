//
//  UIViewImageExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

var userImageCache = [String : UIImage]()

extension UIImageView {
    func scaleImage() {
        autoresizingMask = [.flexibleTopMargin, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth]
        contentMode = UIViewContentMode.scaleAspectFit
        layer.minificationFilter = kCAFilterTrilinear
        clipsToBounds = true
    }

	func loadImages(urlString: String) {
		
		
		guard let url = URL(string: urlString) else { return }
		
		self.image = nil
		
		if let cachedImage = imageCache[urlString] {
			self.image = cachedImage
			return
		}
		
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard error == nil, let imageData = data else {
				print("Failed to fetch post image:", error.debugDescription)
				return
			}
			
			let image = UIImage(data: imageData)
			imageCache[url.absoluteString] = image
			DispatchQueue.main.async {
				self.image = image
			}
			}.resume()
	}
	
	func loadUserImages(by url: String) {
		
		self.image = nil
		if url == "" {
			self.image = #imageLiteral(resourceName: "registration-image-placeholder")
			return
		}
		if let image = userImageCache[url] {
			self.image = image
			return
		}
		
		if let imageUrl = URL(string: url) {
			URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
				if error != nil {
					print("error")
					return
				}
				
				DispatchQueue.main.async(execute: {
					if let image = UIImage(data: data!)?.circleMasked {
						userImageCache[url] = image
						self.image = image	
					} else  {
						self.image = #imageLiteral(resourceName: "registration-image-placeholder")
					}
				})
			}.resume()
		}
	}
	func loadUserImagesWithCompletion(by url: String,_ completion: @escaping () -> Void) {
		if url == "" {
			self.image = #imageLiteral(resourceName: "registration-image-placeholder")
			completion()
		}
		if let image = userImageCache[url] {
			self.image = image
			completion()
		}
		
		if let imageUrl = URL(string: url) {
			URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
				if error != nil {
					print("error")
					completion()
				}
				
				DispatchQueue.main.async(execute: {
					if let image = UIImage(data: data!)?.circleMasked {
						userImageCache[url] = image
						self.image = image
					} else  {
						self.image = #imageLiteral(resourceName: "registration-image-placeholder")
					}
				})
			}.resume()
		}
	}
	func loadUserProfileImages(by url: String,_ completion: @escaping () -> Void) {
		
		self.image = nil
		if url == "" {
			self.image = #imageLiteral(resourceName: "registration-image-placeholder")
			completion()
		}
		if let image = userImageCache[url] {
			self.image = image
			completion()
		}
		
		if let imageUrl = URL(string: url) {
			URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
				if error != nil {
					print("error")
					completion()
				}
				
				DispatchQueue.main.async(execute: {
					if let image = UIImage(data: data!)?.circleMasked {
						userImageCache[url] = image
						self.image = image
					} else  {
						self.image = #imageLiteral(resourceName: "registration-image-placeholder")
					}
					completion()
				})
				}.resume()
		}
	}
}
