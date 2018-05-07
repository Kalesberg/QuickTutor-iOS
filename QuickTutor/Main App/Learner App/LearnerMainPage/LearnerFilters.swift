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
	
	var xButton = NavbarButtonX()
	var applyButton = NavbarButtonText()
	
	override var rightButton: NavbarButton {
		get {
			return applyButton
		} set {
			applyButton = newValue as! NavbarButtonText
		}
	}
	
	override var leftButton: NavbarButton {
		get {
			return xButton
		} set {
			xButton = newValue as! NavbarButtonX
		}
	}
	
	let tableView : UITableView = {
		let tableView = UITableView()
		
		tableView.backgroundColor = .clear
		tableView.estimatedRowHeight = 250
		tableView.isScrollEnabled = true
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.allowsSelection = false
		
		return tableView
	}()
	
	override func configureView() {
		addSubview(tableView)
		super.configureView()
		
		title.label.text = "Filters"
		applyButton.label.label.text = "Apply"
		
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
	var video : Bool = false
	
	var delegate : ApplyLearnerFilters?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureDelegates()
		
	}
	
	private func configureDelegates() {
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.requestLocation()
		
		contentView.tableView.register(EditProfileSliderTableViewCell.self, forCellReuseIdentifier: "editProfileSliderTableViewCell")
		contentView.tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: "toggleTableViewCell")
	}
	
	@objc
	private func rateSliderValueDidChange(_ sender: UISlider!) {
		
		let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditProfileSliderTableViewCell)
		
		cell.valueLabel.text = "$" + String(Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
		price = Int(cell.slider.value.rounded(FloatingPointRoundingRule.up))
	}
	
	@objc
	private func distanceSliderValueDidChange(_ sender: UISlider!) {
		let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! EditProfileSliderTableViewCell)
		
		if ( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
			let value = (Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
			
			if(value % 5 == 0) {
				cell.valueLabel.text = String(value) + " mi"
			}
			distance = value
		} else {
			animateSlider(false)
			showLocationAlert()
		}
	}
	@objc
	private func sliderToggle(_ sender: UISwitch){
		let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! ToggleTableViewCell)
		video = cell.toggle.isOn
		animateSlider(!video)

	}
	
	private func showLocationAlert() {
		let alertController = UIAlertController (title: "Enable Location Services", message: "In order to use this feature you need to enable location services.", preferredStyle: .alert)
		
		let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
			guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
				return
			}
			
			if UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
					
				})
			}
		}
		
		alertController.addAction(settingsAction)
		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
		alertController.addAction(cancelAction)
		
		present(alertController, animated: true, completion: nil)
	}
	
	override func handleNavigation() {
		if touchStartView is NavbarButtonX {
			self.dismiss(animated: true, completion: nil)
		} else if touchStartView is NavbarButtonText {
			
			distance = (distance == 0) ? -1 : distance + 10
			price = (price == 0) ? -1 : price + 10
			
			self.delegate?.filters = (distance, price, video)
			self.delegate?.applyFilters()
			
			self.dismiss(animated: true, completion: nil)
		}
	}
	func animateSlider(_ bool: Bool){
		let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! EditProfileSliderTableViewCell)
		if bool {
			UIView.animate(withDuration: 0.25) {
				cell.slider.setValue(Float(self.distance), animated: true)
			}
			self.distanceSliderValueDidChange(cell.slider)

		} else {
			UIView.animate(withDuration: 0.25) {
				cell.slider.setValue(0.0, animated: true)
				cell.valueLabel.text = "0 mi"
			}
		}
	}
}
extension LearnerFilters : CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.first {
			self.delegate?.location = location
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Failed to find user's location: \(error.localizedDescription)")
	}
}

class ToggleTableViewCell : BaseTableViewCell {
	
	let label : UILabel = {
		let label = UILabel()
		
		label.text = "Search Tutors Online (Video Call)"
		label.textColor = .white
		label.font = Fonts.createBoldSize(15)
		
		return label
	}()
	
	let toggle : UISwitch = {
		let toggle = UISwitch()
		
		toggle.onTintColor = Colors.learnerPurple
		
		return toggle
	}()
	
	override func configureView() {
		addSubview(label)
		addSubview(toggle)
		super.configureView()
		
		selectionStyle = .none
		backgroundColor = .clear
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		label.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.height.equalTo(30)
			make.top.equalToSuperview()
		}
		
		toggle.snp.makeConstraints { (make) in
			make.top.equalTo(label.snp.bottom).inset(-5)
			make.left.equalToSuperview()
			make.height.equalTo(55)
		}
	}
}


extension LearnerFilters : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch (indexPath.row) {
		case 0:
			return 30
		case 1:
			return UITableViewAutomaticDimension
		case 2:
			return UITableViewAutomaticDimension
		case 3:
			return 90
		case 4:
			return UITableViewAutomaticDimension
		default:
			break
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch (indexPath.row) {
		case 0:
			let cell = UITableViewCell()
			cell.backgroundColor = .clear
			return cell
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell
			
			cell.slider.addTarget(self, action: #selector(rateSliderValueDidChange), for: .valueChanged)
			cell.slider.minimumTrackTintColor = Colors.learnerPurple
			
			cell.slider.minimumValue = 5
			cell.slider.maximumValue = 100
			
			let formattedString = NSMutableAttributedString()
			formattedString
				.bold("Maximum Hourly Rate  ", 15, .white)
				.regular("  [$5-$100]", 15, Colors.grayText)
			
			cell.header.attributedText = formattedString
			
			return cell
		case 2:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell
			
			cell.slider.addTarget(self, action: #selector(distanceSliderValueDidChange), for: .valueChanged)
			cell.slider.minimumTrackTintColor = Colors.learnerPurple
			
			cell.slider.minimumValue = 5
			cell.slider.maximumValue = 150
			
			let formattedString = NSMutableAttributedString()
			formattedString
				.bold("Maximum Travel Distance  ", 15, .white)
				.regular("  [0-150 mi]", 15, Colors.grayText)
			
			cell.header.attributedText = formattedString
			
			return cell
		case 3:
			let cell = tableView.dequeueReusableCell(withIdentifier: "toggleTableViewCell", for: indexPath) as! ToggleTableViewCell
			
			cell.toggle.addTarget(self, action: #selector(sliderToggle(_:)), for: .touchUpInside)
			
			
			
			return cell
		case 4:
			let cell = UITableViewCell()
			
			cell.backgroundColor = .clear
			
			let label = UILabel()
			cell.contentView.addSubview(label)
			
			let formattedString = NSMutableAttributedString()
			formattedString
				.bold("Distance Setting\n", 16, .white)
				.regular("You will only be able to view tutors who are within your set maximum distance setting.\n\n", 15, Colors.grayText)
				.bold("Video Calls - Search the World\n", 16, .white)
				.regular("This option enables you to also view tutors around the world, so you can connect for video call sessions.\n\n", 15, Colors.grayText)
				.bold("Hourly Rate\n", 16, .white)
				.regular("We'll provide you with tutors who are within your price range. However, each individual session is negotiable to any price.", 15, Colors.grayText)
			
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
			break
		}
		
		return UITableViewCell()
	}
}
