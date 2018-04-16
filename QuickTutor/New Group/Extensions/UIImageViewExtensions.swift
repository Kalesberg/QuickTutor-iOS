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
					}
				})
			}.resume()
		}
	}
}
