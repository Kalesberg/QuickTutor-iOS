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
	
	init(addressString: String) {
		convertAddressToLatLong(addressString: addressString) { (error) in
			if let error = error {
				print(error.localizedDescription)
			} else {
				print("Success")
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

			if pm.subThoroughfare != nil {
				addressString = addressString + pm.subThoroughfare! + " "
			}
			if pm.subLocality != nil {
				addressString = addressString + pm.subLocality! + ", "
			}
			if pm.thoroughfare != nil {
				addressString = addressString + pm.thoroughfare! + ", "
			}
			if pm.locality != nil {
				addressString = addressString + pm.locality! + ", "
			}
			if pm.administrativeArea != nil {
				addressString = addressString + pm.administrativeArea! + " "
			}
			if pm.postalCode != nil {
				addressString = addressString + pm.postalCode! + " "
			}
			TutorRegistration.address = addressString
		}
	}
}

