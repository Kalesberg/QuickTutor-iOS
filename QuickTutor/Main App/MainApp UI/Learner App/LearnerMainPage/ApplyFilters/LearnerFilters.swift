//
//  LearnerFilters.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LearnerFiltersView : MainLayoutTitleTwoButton {
	
	var xButton = NavbarButtonXLight()
	var applyButton = NavbarButtonApply()
	
	override var rightButton: NavbarButton {
		get {
			return applyButton
		} set {
			applyButton = newValue as! NavbarButtonApply
		}
	}
	
	override var leftButton: NavbarButton {
		get {
			return xButton
		} set {
			xButton = newValue as! NavbarButtonXLight
		}
	}
	
	let tableView : UITableView = {
		let tableView = UITableView()
		
		tableView.backgroundColor = .clear
		tableView.estimatedRowHeight = 250
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.sectionHeaderHeight = 20
		tableView.allowsSelection = false
		
		return tableView
	}()
	
	override func configureView() {
		addSubview(tableView)
		super.configureView()
		
		title.label.text = "Filters"
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.leading.equalTo(layoutMarginsGuide.snp.leading)
			make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
			} else {
				make.bottom.equalToSuperview()
			}
		}
	}
}

class LearnerFilters: BaseViewController {
	
	override var contentView: LearnerFiltersView {
		return view as! LearnerFiltersView
	}
	
	override func loadView() {
		view = LearnerFiltersView()
	}
	
	let locationManager = CLLocationManager()
	
	var price : Int = 0
	var distance : Int = 0
	var sessionType : Bool = false
	var location : CLLocation?
	
	
	var filters : Filters?
	var delegate : UpdatedFiltersCallback?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		hideKeyboardWhenTappedAround()
		configureDelegates()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.tableView.reloadData()
	}
	
	private func configureDelegates() {
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.requestLocation()
		
		contentView.tableView.register(EditProfileSliderTableViewCell.self, forCellReuseIdentifier: "editProfileSliderTableViewCell")
		contentView.tableView.register(EditProfileHourlyRateTableViewCell.self, forCellReuseIdentifier: "editProfileHourlyRateTableViewCell")
		contentView.tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: "toggleTableViewCell")
	}
	
	@objc
	private func distanceSliderValueDidChange(_ sender: UISlider!) {
		let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditProfileSliderTableViewCell)
		if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
			let value = (Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
			cell.valueLabel.text = (value == 0) ? "" : String(value) + " mi"
			distance = value
		} else {
			animateSlider(false)
			showLocationAlert()
		}
	}
	@objc
	private func sliderToggle(_ sender: UISwitch) {
		guard let cell = contentView.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? ToggleTableViewCell else { return }
		
		print("Called.")
		sessionType = cell.toggle.isOn
		animateSlider(!sessionType)
		
		guard let distanceSlider = contentView.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditProfileSliderTableViewCell else { return }
		
		distanceSlider.slider.isEnabled = !cell.toggle.isOn
	}
	
	private func showLocationAlert() {
		let alertController = UIAlertController (title: "Enable Location Services", message: "In order to use this feature you need to enable location services.", preferredStyle: .alert)
		let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
			guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
				return
			}
			if UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl, completionHandler: nil)
			}
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

		alertController.addAction(settingsAction)
		alertController.addAction(cancelAction)
		
		present(alertController, animated: true, completion: nil)
	}

	func updateFilters() -> Filters {
		let priceCell = (contentView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditProfileHourlyRateTableViewCell)
		let distanceCell = (contentView.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditProfileSliderTableViewCell)
		let toggleCell = (contentView.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! ToggleTableViewCell)
		
		let value = (Int(distanceCell.slider.value.rounded(FloatingPointRoundingRule.up)))
		let distanceFilter = (value == 0) ? nil : value
		
		return Filters(distance: distanceFilter, price:  Int(priceCell.amount), inPerson: toggleCell.toggle.isOn, location: location)
	}
	
	override func handleNavigation() {
		if touchStartView is NavbarButtonXLight {
			self.dismiss(animated: true, completion: nil)
		} else if touchStartView is NavbarButtonApply {
			self.delegate?.filtersUpdated(filters: updateFilters())
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	func animateSlider(_ bool: Bool){
		let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditProfileSliderTableViewCell)
		if bool {
			UIView.animate(withDuration: 0.25) {
				cell.slider.setValue(Float(self.distance), animated: true)
				cell.valueLabel.text = (self.distance > 0) ? String(self.distance) + " mi" : ""
			}
			self.distanceSliderValueDidChange(cell.slider)
		} else {
			UIView.animate(withDuration: 0.25) {
				cell.slider.setValue(0.0, animated: true)
				cell.valueLabel.text = ""
			}
		}
	}
}

extension LearnerFilters : CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.first {
			self.location = location
		}
	}
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Failed to find user's location: \(error.localizedDescription)")
	}
}



extension LearnerFilters : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch (indexPath.row) {
		case 0,1,3:
			return UITableViewAutomaticDimension
		case 2:
			return 90
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch (indexPath.row) {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHourlyRateTableViewCell", for: indexPath) as! EditProfileHourlyRateTableViewCell
			let formattedString = NSMutableAttributedString()
			formattedString
				.bold("\nHourly Rate  ", 15, .white)
				.regular("  [$5-$1000]", 15, Colors.grayText)

			cell.header.attributedText = formattedString
			if let price = filters?.price {
				cell.textField.text = "$\(price)"
				cell.amount = "\(price)"
				cell.currentPrice = price
			} else {
				cell.textField.text = "$5"
			}
			
			return cell
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell
			
			cell.slider.addTarget(self, action: #selector(distanceSliderValueDidChange), for: .valueChanged)
			cell.slider.minimumTrackTintColor = Colors.learnerPurple
			cell.slider.minimumValue = 0
			cell.slider.maximumValue = 150
			
			if let distance = filters?.distance {
				cell.valueLabel.text = (distance > 0) ? String(distance) + " mi" : ""
				cell.slider.value = Float(distance)
			} else {
				cell.valueLabel.text = ""
				cell.slider.value = Float(distance)
			}
			
			if let sessionType = filters?.sessionType {
				cell.slider.isEnabled = !sessionType
			}
			
			

			let formattedString = NSMutableAttributedString()
			formattedString
				.regular("\n\n", 5, .white)
				.bold("Distance Setting  ", 15, .white)
				.regular("  [0-150 mi]", 15, Colors.grayText)
			
			cell.header.attributedText = formattedString
			
			return cell
		case 2:
			let cell = tableView.dequeueReusableCell(withIdentifier: "toggleTableViewCell", for: indexPath) as! ToggleTableViewCell
			
			cell.toggle.addTarget(self, action: #selector(sliderToggle(_:)), for: .allEvents)
			
			if let sessionType = filters?.sessionType {
				cell.toggle.setOn(sessionType, animated: true)
			} else {
				cell.toggle.setOn(false, animated: true)
			}
			
			return cell
		case 3:
			let cell = UITableViewCell()
			
			cell.backgroundColor = .clear
			
			let label = UILabel()
			cell.contentView.addSubview(label)
			
			let formattedString = NSMutableAttributedString()
			formattedString
                .bold("Maximum Hourly Rate\n", 16, .white)
                .regular("We'll provide you with tutors who are within your price range. However, each individual session is negotiable to any price -- message a tutor to figure out the details.\n\n", 15, Colors.grayText)
				.bold("Distance Setting\n", 16, .white)
				.regular("You will only be able to view tutors who are within your set maximum distance setting.\n\n", 15, Colors.grayText)
				.bold("Search Online Tutors\n", 16, .white)
				.regular("This option enables you also to view tutors around the world who are outside your distance setting so that you can connect for video call sessions.\n\n", 15, Colors.grayText)
			
			label.attributedText = formattedString
			label.numberOfLines = 0
			
			label.snp.makeConstraints { (make) in
				make.width.equalToSuperview()
				make.centerX.equalToSuperview()
				make.top.equalToSuperview()
				make.bottom.equalToSuperview()
			}
			return cell
		default:
			return UITableViewCell()
		}
	}
}
