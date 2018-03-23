//
//  LocationServices.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import CoreLocation
import Firebase
//
//class LocationServices {
//	
//	static let manager = LocationServices()
//	
//	let geoCoder = CLGeocoder()
//	
//	func coordinates(_ address: String) {
//		geoCoder.geocodeAddressString(address) { (placemarks, error) in
//			guard
//				let placemark = placemarks,
//				let location = placemark.first?.location
//				else {
//					print("No Coords")
//					return
//			}
//			FirebaseData.manager.updateValue(value: ["lat" : location.coordinate.latitude])
//			FirebaseData.manager.updateValue(value: ["long" : location.coordinate.longitude])
//			self.addressString(location)
//		}
//	}
//	
//	private func addressString(_ location: CLLocation) {
//		self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
//			guard
//				let placemark = placemarks,
//				let address = placemark.first?.postalAddress
//				else {
//					return
//			}
//			FirebaseData.manager.updateValue(value: ["adr" : "\(address.city), \(address.state)"])
//		})
//	}
//}

