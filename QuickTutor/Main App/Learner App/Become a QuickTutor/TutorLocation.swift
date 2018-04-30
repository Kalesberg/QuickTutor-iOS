//
//  TutorLocation.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import CoreLocation

class TutorLocation {
	
	let geoCoder = CLGeocoder()
	static let shared = TutorLocation()
	
	func convertAddressToLatLong(addressString : String, completion: @escaping (Error?) -> Void) {
		geoCoder.geocodeAddressString(addressString) { (placemark, error) in
			if let error = error {
				completion(error)
			}
			if let placemark = placemark?.first {
				TutorRegistration.location = placemark.location
				self.formatAddressStringFromLatLong(location: placemark.location!)
				completion(nil)
			}
		}
	}
	
	func formatAddressStringFromLatLong(location: CLLocation) {
		geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
			if let error = error {
				print(error.localizedDescription)
			}
		
			guard let placemark = placemarks, placemark.count > 0 else {
				print("Reverse Geocode did not work.")
				return
			}
			
			let pm = placemark[0]
			var line1 : String = ""
			var addressString : String = ""

			if let streetNumber = pm.subThoroughfare {
				line1 = line1 + streetNumber + " "
			}
			if let street = pm.thoroughfare {
				addressString = line1 + street
				TutorRegistration.line1 = line1 + street
			}
			
			if let city = pm.locality {
				addressString = addressString + city + ", "
				TutorRegistration.city = city
			}
			if let state = pm.administrativeArea {
				addressString = addressString + state + " "
				TutorRegistration.state = state
			}
			if let zipcode = pm.postalCode {
				addressString = addressString + zipcode + " "
				TutorRegistration.zipcode = zipcode
			}
			TutorRegistration.address = addressString
		}
	}
}

