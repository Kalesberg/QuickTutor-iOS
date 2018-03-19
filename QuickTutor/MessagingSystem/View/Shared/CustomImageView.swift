//
//  CustomImageView.swift
//  QuickTutorMessaging
//
//  Created by Brian Voong on 2/7/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        self.lastURLUsedToLoadImage = urlString
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
            
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            
            let image = UIImage(data: imageData)
            imageCache[url.absoluteString] = image
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
