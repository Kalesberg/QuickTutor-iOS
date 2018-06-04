//
//  TutorManagePreferences.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorManagePreferencesView : MainLayoutTitleBackSaveButton {
	
	let tableView : UITableView = {
		let tableView = UITableView()
		
		tableView.backgroundColor = .clear
		tableView.estimatedRowHeight = 250
		tableView.isScrollEnabled = true
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		
		return tableView
	}()
	
	override func configureView() {
		addSubview(tableView)
		super.configureView()
		
		title.label.text = "Manage Preferences"

	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-8)
			make.leading.equalTo(layoutMarginsGuide.snp.leading)
			make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
			make.bottom.equalTo(safeAreaLayoutGuide)
		}
	}
	override func layoutSubviews() {
		statusbarView.backgroundColor = Colors.tutorBlue
		navbar.backgroundColor = Colors.tutorBlue
	}
}

class TutorManagePreferences : BaseViewController {
	
	override var contentView: TutorManagePreferencesView {
		return view as! TutorManagePreferencesView
	}
	
	var tutor : AWTutor! {
		didSet {
			contentView.tableView.reloadData()
		}
	}
	var distance: Int!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.hideKeyboardWhenTappedAround()
		configureDelegates()
	}
	
	override func loadView() {
		view = TutorManagePreferencesView()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	private func configureDelegates() {
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		
		contentView.tableView.register(EditProfileHourlyRateTableViewCell.self, forCellReuseIdentifier: "editProfileHourlyRateTableViewCell")
		contentView.tableView.register(EditProfileSliderTableViewCell.self, forCellReuseIdentifier: "editProfileSliderTableViewCell")
		contentView.tableView.register(EditProfileCheckboxTableViewCell.self, forCellReuseIdentifier: "editProfileCheckboxTableViewCell")
	}
	
	@objc
	private func distanceSliderValueDidChange(_ sender: UISlider) {
		let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditProfileSliderTableViewCell)
		let value = (Int(cell.slider.value.rounded(FloatingPointRoundingRule.up)))
		
		cell.valueLabel.text = "\(value) mi"
		distance = value
	}
	
	private func displaySavedAlertController() {
		let alertController = UIAlertController(title: "Saved!", message: "Your changes have been saved", preferredStyle: .alert)
		
		self.present(alertController, animated: true, completion: nil)
		
		let when = DispatchTime.now() + 1
		DispatchQueue.main.asyncAfter(deadline: when){
			alertController.dismiss(animated: true){
				self.navigationController?.popViewController(animated: true)
			}
		}
	}
	
	private func setUserPreferences() {
		var preference : Int = 0
		let cell = (contentView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditProfileHourlyRateTableViewCell)
		
		guard let price = Int(cell.amount) else {
			print("Error: Price")
			return
		}
		
		let cell2 = (contentView.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! EditProfileCheckboxTableViewCell)
		let inPerson = cell2.checkbox.isSelected
		
		let cell3 = (contentView.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! EditProfileCheckboxTableViewCell)
		let inVideo = cell3.checkbox.isSelected
		
		
		if inPerson && inVideo {
			preference = 3
		} else if inPerson && !inVideo {
			preference = 2
		} else if !inPerson && inVideo {
			preference = 1
		} else {
			preference = 0
		}
		FirebaseData.manager.updateTutorPreferences(uid: tutor.uid, price: price, distance: self.distance, preference: preference) { (error) in
			if let error = error {
				AlertController.genericErrorAlert(self, title: "Error Uploading Preferences", message: error.localizedDescription)
			} else {
				CurrentUser.shared.tutor.price = price
				CurrentUser.shared.tutor.distance = self.distance
				CurrentUser.shared.tutor.preference = preference
				self.displaySavedAlertController()
			}
		}
	}
	
	override func handleNavigation() {
		if (touchStartView is NavbarButtonSave) {
			setUserPreferences()
		}
	}
}


extension TutorManagePreferences : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch (indexPath.row) {
			
		case 0:
			return UITableViewAutomaticDimension
		case 1:
			return UITableViewAutomaticDimension
		case 2:
			return 40
		case 3:
			return 40
		default:
			break
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch (indexPath.row) {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHourlyRateTableViewCell", for: indexPath) as! EditProfileHourlyRateTableViewCell
			
			let formattedString = NSMutableAttributedString()
			formattedString
				.regular("\n", 5, .white)
				.bold("\nHourly Rate  ", 15, .white)
				.regular("  [$5-$1000]\n", 15, Colors.grayText)
				.regular("\n", 8, .white)
				.regular("Please set your general hourly rate.\n\nAlthough you have a set rate, individual sessions can be negotiable.", 14, Colors.grayText)
			
			cell.header.attributedText = formattedString
			
			cell.textField.text = "$\(tutor.price!)"
			cell.amount = String(tutor.price!)
			cell.currentPrice = tutor.price!
			return cell
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileSliderTableViewCell", for: indexPath) as! EditProfileSliderTableViewCell
			
			cell.slider.addTarget(self, action: #selector(distanceSliderValueDidChange), for: .valueChanged)
			
			cell.slider.minimumValue = 5
			cell.slider.maximumValue = 150
			
			let formattedString = NSMutableAttributedString()
			formattedString
				.regular("\n", 5, .white)
				.bold("\nTravel Distance  ", 15, .white)
				.regular("  [0-150 mi]\n", 15, Colors.grayText)
				.regular("\n", 8, .white)
				.regular("Please set the maximum number of miles you are willing to travel for a tutoring session.", 14, Colors.grayText)
			
			cell.header.attributedText = formattedString
			cell.valueLabel.text = "\(tutor.distance!) mi"
			cell.slider.value = Float(tutor.distance!)
			self.distance = tutor.distance
			
			return cell
		case 2:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCheckboxTableViewCell", for: indexPath) as! EditProfileCheckboxTableViewCell
			
			cell.label.text = "Tutoring In-Person Sessions?"
			cell.checkbox.isSelected = (tutor.preference == 3 || tutor.preference == 2)
			return cell
		case 3:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCheckboxTableViewCell", for: indexPath) as! EditProfileCheckboxTableViewCell

			cell.label.text = "Tutoring Online (Video Call) Sessions?"
			cell.checkbox.isSelected = (tutor.preference == 3 || tutor.preference == 1)
			return cell
		default:
			break
		}
		
		return UITableViewCell()
	}
}
