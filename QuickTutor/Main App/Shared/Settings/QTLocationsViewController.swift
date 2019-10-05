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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var address: String?
    
    private var searchSource: [String]?
    let searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    static var controller: QTLocationsViewController {
        return QTLocationsViewController(nibName: String(describing: QTLocationsViewController.self), bundle: nil)
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        // Register a nib
        tableView.register(QTLocationTableViewCell.nib, forCellReuseIdentifier: QTLocationTableViewCell.resuableIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 54
        tableView.separatorColor = UIColor.clear
        
        searchCompleter.delegate = self
        searchCompleter.filterType = .locationsOnly
        
        // search bar
        searchBar.delegate = self
        searchBar.text = address
        
        // add notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow (_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide (_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
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
    
    // MARK: - Search Handlers
    private func searchLocations (_ searchText: String) {
        guard searchText.count > 0, searchText != "" else {
            searchResults = []
            tableView.reloadData()
            return
        }
        searchCompleter.queryFragment = searchText
    }
    
    // MARK: - Notification Handler
    @objc
    private func keyboardWillShow (_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            tableView.contentInset = UIEdgeInsets (top: 0.0, left: 0.0, bottom: keyboardFrame.cgRectValue.height, right: 0.0)
        }
    }
    
    @objc
    private func keyboardWillHide (_ notification: Notification) {
        tableView.contentInset = UIEdgeInsets (top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
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
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        
        let addressString = "\(searchResults[indexPath.row].title) \(searchResults[indexPath.row].subtitle)"
        
        getCoordinate(addressString: addressString) { (location, error) in
            if let error = error {
                AlertController.genericErrorAlertWithoutCancel(self, title: "Error", message: error.localizedDescription)
            }
            self.formatAddressIntoRegion(location: CLLocation(latitude: location.latitude, longitude: location.longitude), { (region, error) in
                if error != nil {
                    AlertController.genericErrorAlertWithoutCancel(self, title: "Error", message: "Unable to successfully find location. Please try again.")
                } else if let region = region {
                    if AccountService.shared.currentUserType == .learner {
                        CurrentUser.shared.learner.region = region
                        FirebaseData.manager.updateValue(node: "student-info", value: ["rg": region]) { error in
                            if let error = error {
                                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                            }
                        }
                        
                        // save location
                        if CurrentUser.shared.learner.location == nil {
                            FirebaseData.manager.geoFire(location: CLLocation(latitude: location.latitude, longitude: location.longitude)) { isSuccess in
                                if isSuccess {
                                    FirebaseData.manager.fetchLearnerLocation(uid: CurrentUser.shared.learner.uid!, { location in
                                        CurrentUser.shared.learner.location = location
                                    })
                                }
                            }
                        } else {
                            FirebaseData.manager.geoFire(location: CLLocation(latitude: location.latitude, longitude: location.longitude))
                            CurrentUser.shared.learner.location?.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
                        }
                    } else {
                        FirebaseData.manager.updateFeaturedTutorRegion(CurrentUser.shared.learner.uid!, region: region)
                        CurrentUser.shared.tutor.region = region
                        Tutor.shared.updateValue(value: ["rg" : region])
                        
                        if CurrentUser.shared.tutor.location == nil {
                            Tutor.shared.geoFire(location: CLLocation(latitude: location.latitude, longitude: location.longitude)) { isSuccess in
                                if isSuccess {
                                    FirebaseData.manager.fetchTutorLocation(uid: CurrentUser.shared.learner.uid!, { location in
                                        CurrentUser.shared.tutor.location = location
                                    })
                                }
                            }
                        } else {
                            CurrentUser.shared.tutor.location?.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
                            Tutor.shared.geoFire(location: CLLocation(latitude: location.latitude, longitude: location.longitude))
                        }
                    }
                    
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
        if let cell: QTLocationTableViewCell = tableView.dequeueReusableCell(withIdentifier: QTLocationTableViewCell.resuableIdentifier,
                                                                              for: indexPath) as? QTLocationTableViewCell {
            cell.setData(landmark: searchResult.title, address: searchResult.subtitle)
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

extension QTLocationsViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchLocations("")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchLocations(searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}


