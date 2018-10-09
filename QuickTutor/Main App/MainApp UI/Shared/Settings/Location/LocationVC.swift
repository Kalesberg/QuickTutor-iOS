//
//  Location.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import MapKit

class LocationVC : BaseViewController {
	override var contentView: LocationView {
		return view as! LocationView
	}
	override func loadView() {
		view = LocationView()
	}
	
	var searchSource: [String]?
	let searchCompleter = MKLocalSearchCompleter()
	var searchResults = [MKLocalSearchCompletion]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		searchCompleter.delegate = self

		contentView.tableView.dataSource = self
		contentView.tableView.delegate = self
		contentView.searchTextField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.searchTextField.textField.becomeFirstResponder()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	@objc private func textFieldDidChange(_ textField: UITextField) {
		guard let searchText = textField.text, searchText.count > 0, searchText != "" else {
			searchResults = []
			contentView.tableView.reloadData()
			return
		}
		searchCompleter.queryFragment = searchText
	}
	func getCoordinate(addressString : String, completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void) {
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(addressString) { (placemarks, error) in
			if error == nil {
				if let placemark = placemarks?[0] {
					let location = placemark.location!
					completionHandler(location.coordinate, nil)
					return
				}
			}
			completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
		}
	}
	func formatAddressIntoRegion(location: CLLocation, _ completion: @escaping (String?, Error?) -> Void) {
		let geoCoder = CLGeocoder()
		
		geoCoder.reverseGeocodeLocation(location) { placemarks, error in
			if let error = error {
				print(error.localizedDescription)
				completion(nil, error)
			}
			guard let placemark = placemarks, placemark.count > 0 else {
				return completion(nil,  NSError(domain: "", code: 100, userInfo: nil) as Error)
			}
			
			let pm = placemark[0]
			var addressString: String = ""
			
			if let city = pm.locality {
				addressString = addressString + city + ", "
			}
			if let state = pm.administrativeArea {
				addressString = addressString + state + " "
			}
			completion(addressString, nil)
		}
	}
}

extension LocationVC : MKLocalSearchCompleterDelegate {
	func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
		searchResults = completer.results
		contentView.tableView.reloadData()
	}
	func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
		print(error.localizedDescription)
	}
}

extension LocationVC : UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchResults.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let searchResult = searchResults[indexPath.row]
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
		
		let cellBackground = UIView()
		cellBackground.backgroundColor = Colors.navBarColor
		cell.selectedBackgroundView = cellBackground

		cell.backgroundColor = Colors.backgroundDark
		cell.textLabel?.textColor = .white
		cell.textLabel?.text = searchResult.title
		cell.detailTextLabel?.text = searchResult.subtitle
		cell.detailTextLabel?.textColor = .white
		
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let addressString = "\(searchResults[indexPath.row].title) \(searchResults[indexPath.row].subtitle)"
		
		getCoordinate(addressString: addressString) { (location, error) in
			if let error = error {
				print(error.localizedDescription)
			}
			self.formatAddressIntoRegion(location: CLLocation(latitude: location.latitude, longitude: location.longitude), { (region, error) in
				if error != nil {
					AlertController.genericErrorAlertWithoutCancel(self, title: "Error", message: "Unable to successfully find location. Please try again.")
				} else if let region = region {
					print("Region: ", region)
					CurrentUser.shared.tutor.location?.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
					CurrentUser.shared.tutor.region = region
					Tutor.shared.updateValue(value: ["rg" : region])
					Tutor.shared.geoFire(location: CLLocation(latitude: location.latitude, longitude: location.longitude))
					
					AlertController.genericSavedAlert(self, title: "Addressed Saved!", message: "This address has been saved.")
				}
			})
		}
	}
}

extension LocationVC: UIScrollViewDelegate {
	func scrollViewWillBeginDragging(_: UIScrollView) {
		view.endEditing(true)
	}
}
