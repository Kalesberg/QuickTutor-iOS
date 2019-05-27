//
//  EditBirthdateVC.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class EditBirthdateVC: BaseViewController {
	
	let date = Date()
	let dateformatter = DateFormatter()
	let calendar = Calendar.current
	var birthdateString : String = ""
	
	override var contentView: BirthdayVCView {
		return view as! BirthdayVCView
	}
	
	override func loadView() {
		view = BirthdayVCView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        contentView.datePicker.maximumDate = Date().adding(days: 365 * -18)
        contentView.titleLabel.text = "Enter birthday"
		dateformatter.dateFormat = "MMMM d'\(date.daySuffix())' yyyy"
		contentView.birthdayLabel.textField.text = CurrentUser.shared.learner.birthday.toBirthdatePrettyFormat()
		contentView.datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.title = "Edit Birthday"
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"newCheck"), style: .plain, target: self, action: #selector(saveChanges))
        
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Hide the bottom tab bar and relayout views
        tabBarController?.tabBar.isHidden = true
        edgesForExtendedLayout = .bottom
        extendedLayoutIncludesOpaqueBars = true
    }
    
	private func showErrorMessage() {
		contentView.errorLabel.isHidden = false
		contentView.errorLabel.shake()
	}

	private func checkAgeAndBirthdate() -> Bool {
		let birthdate = contentView.datePicker.calendar!
		let birthday = birthdate.dateComponents([.day, .month, .year], from: contentView.datePicker.date)
		let age = birthdate.dateComponents([.year], from: contentView.datePicker.date, to: date)
		
		guard let yearsOld = age.year, yearsOld >= 18,
			let day = birthday.day,
			let month = birthday.month,
			let year = birthday.year
		else {
				return false
		}
		
		birthdateString = String("\(day)/\(month)/\(year)")
		contentView.errorLabel.isHidden = true
		
		return true
	}
    
    @objc func saveChanges() {
        if checkAgeAndBirthdate() && birthdateString != "" {
            FirebaseData.manager.updateAge(CurrentUser.shared.learner.uid!, birthdate: birthdateString) { (error) in
                if let error = error {
                    AlertController.genericErrorAlertWithoutCancel(self, title: "Error!", message: error.localizedDescription)
                }
                AlertController.genericSavedAlert(self, title: "Saved!", message: "Your birthdate has been saved!")
                CurrentUser.shared.learner.birthday = self.birthdateString
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            showErrorMessage()
        }
    }
	
	@objc func datePickerValueChanged(_ sender: UIDatePicker) {
		dateformatter.dateFormat = "MMMM d'\(contentView.datePicker.date.daySuffix())' yyyy"
		let date = dateformatter.string(from: contentView.datePicker.date)
		UIView.animate(withDuration: 0.2, animations: {
			self.contentView.birthdayLabel.textField.transform.scaledBy(x: 0.95, y: 0.95)
			self.contentView.birthdayLabel.textField.alpha = 0
		}) { (_) in
			UIView.animate(withDuration: 0.2, animations: {
				self.contentView.birthdayLabel.textField.alpha = 1
				self.contentView.birthdayLabel.textField.text! = date
				self.contentView.birthdayLabel.textField.transform = .identity
			})
		}
	}
}
