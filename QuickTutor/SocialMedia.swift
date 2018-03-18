//
//  SocialMedia.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
// Purpose: To handle all Social Media actions on the platform. This class will continue to grow with new functionality
// as we see fit.

/* TODO: Backend
	Get itunes App Id and test to make sure it works.
	Add functionality to know when user clicks rate, follow, etc.
	Instragram API
	Share on Facebook, Instagram, Twitter, etc.

	TODO: Future
	Rate app, send tweets, posts, pictures, without having to leave app. similar to slack
	incorporate longpress gesture on app icon to also post things to social media.

*/

import UIKit
class SocialMedia {
	
	static let socialMediaManager = SocialMedia()
	
	func rateApp(appUrl: String, webUrl : String, completion: @escaping ((_ success : Bool) -> ())) {
		guard let url = URL(string: appUrl) else {
			completion(false)
			return
		}
		if UIApplication.shared.canOpenURL(url) {
			if #available(iOS 10, *) {
				UIApplication.shared.open(url, options: [:], completionHandler: completion)
			} else{
				UIApplication.shared.open(url)
			}
		} else {
			guard let url = URL(string: webUrl) else {
				completion(false)
				return
			}
			if #available(iOS 10, *) {
				UIApplication.shared.open(url, options: [:], completionHandler: completion)
			} else {
				UIApplication.shared.openURL(url)
			}
		}
	}
}
