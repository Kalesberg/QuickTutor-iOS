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
	
	init(addressString: String, completion: @escaping (Error?) -> Void) {
		convertAddressToLatLong(addressString: addressString) { (error) in
			if let error = error {
				completion(error)
			} else {
				completion(nil)
			}
		}
	}
	
	func convertAddressToLatLong(addressString : String, completion: @escaping (Error?) -> Void) {
		geoCoder.geocodeAddressString(addressString) { (placemark, error) in
			if let error = error {
				completion(error)
			}
			if let placemark = placemark?.first {
				TutorRegistration.location = placemark.location?.coordinate
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
			var addressString : String = ""

			if let streetNumber = pm.subThoroughfare {
				addressString = addressString + streetNumber + " "
			}
			if let street = pm.thoroughfare {
				TutorRegistration.line1 = addressString + street
				addressString = addressString + street + ", "
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

