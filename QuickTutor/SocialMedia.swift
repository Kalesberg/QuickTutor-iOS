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
	
	class func rateApp(appUrl: String, webUrl : String, completion: @escaping ((_ success : Bool) -> ())) {
		guard let url = URL(string: appUrl) else {
			completion(false)
			return
		}
		if UIApplication.shared.canOpenURL(url) {
			if #available(iOS 10, *) {
				UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: completion)
			} else{
				UIApplication.shared.open(url)
			}
		} else {
			guard let url = URL(string: webUrl) else {
				return completion(false)
			}
			if #available(iOS 10, *) {
				UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: completion)
			} else {
				UIApplication.shared.openURL(url)
			}
		}
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
