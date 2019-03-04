//
//  QTLocationsViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 3/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import MapKit

class QTLocationsViewController: UIViewController {

    // MARK: - variables
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var address: String?
    
    var searchSource: [String]?
    let searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    static func loadView() -> QTLocationsViewController {
        return QTLocationsViewController(nibName: String(describing: QTLocationsViewController.self), bundle: nil)
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()

        searchView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.1, offset: CGSize(width: 0, height: 1), radius: 5.0)
        
        // Register a nib
        tableView.register(QTLocationTableViewCell.nib(), forCellReuseIdentifier: QTLocationTableViewCell.resuableIdentifier())
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 54
        tableView.separatorColor = UIColor.clear
        
        searchCompleter.delegate = self
        searchCompleter.filterType = .locationsOnly
        
        searchTextField.addTarget(self, action: #selector(handleSearchTextFieldChange(_:)), for: .editingChanged)
        searchTextField.text = address
        closeButton.isHidden = address?.isEmpty ?? true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    // MARK: - actions
    @IBAction func onCloseButtonClicked(_ sender: Any) {
        searchTextField.text = ""
        closeButton.isHidden = true
    }
    
    @objc
    func handleSearchTextFieldChange(_ textField: UITextField) {
        guard let searchText = textField.text, searchText.count > 0, searchText != "" else {
            closeButton.isHidden = true
            searchResults = []
            tableView.reloadData()
            return
        }
        closeButton.isHidden = false
        searchCompleter.queryFragment = searchText
    }
    
    // MARK: - private functions
    func setupNavBar() {
        navigationItem.title = "Location"
        navigationController?.setNavigationBarHidden(false, animated: true)
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
                return completion(nil, error)
            }
            guard let placemark = placemarks, placemark.count > 0 else {
                return completion(nil,  NSError(domain: "", code: 100, userInfo: nil) as Error)
            }
            
            let pm = placemark[0]
            var addressString: String = ""
            
            if let city = pm.locality {
                addressString = city + ", "
            }
            if let state = pm.administrativeArea {
                addressString = addressString + state
            }
            completion(addressString, nil)
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension QTLocationsViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - UITableViewDelegate
extension QTLocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addressString = "\(searchResults[indexPath.row].title) \(searchResults[indexPath.row].subtitle)"
        
        getCoordinate(addressString: addressString) { (location, error) in
            if let error = error {
                AlertController.genericErrorAlertWithoutCancel(self, title: "Error", message: error.localizedDescription)
            }
            self.formatAddressIntoRegion(location: CLLocation(latitude: location.latitude, longitude: location.longitude), { (region, error) in
                if error != nil {
                    AlertController.genericErrorAlertWithoutCancel(self, title: "Error", message: "Unable to successfully find location. Please try again.")
                } else if let region = region {
                    FirebaseData.manager.updateFeaturedTutorRegion(CurrentUser.shared.learner.uid!, region: region)
                    CurrentUser.shared.tutor.location?.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    CurrentUser.shared.tutor.region = region
                    Tutor.shared.updateValue(value: ["rg" : region])
                    Tutor.shared.geoFire(location: CLLocation(latitude: location.latitude, longitude: location.longitude))
                    AlertController.genericSavedAlert(self, title: "Address Saved!", message: "This address has been saved.")
                }
            })
        }
    }
}

// MARK: - UITableViewDataSource
extension QTLocationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        if let cell: QTLocationTableViewCell = tableView.dequeueReusableCell(withIdentifier: QTLocationTableViewCell.resuableIdentifier(),
                                                                              for: indexPath) as? QTLocationTableViewCell {
            cell.setData(landmark: searchResult.title, address: searchResult.subtitle)
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK: - UIScrollViewDelegate
extension QTLocationsViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_: UIScrollView) {
        view.endEditing(true)
    }
}
