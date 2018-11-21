//
//  Birthday.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/19/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit

class BirthdayView: RegistrationNavBarView {
    
    let birthdayPicker = RegistrationDatePicker()
    let contentView = UIView()
	
	let birthdayLabel : RegistrationTextField = {
		let label = RegistrationTextField()
		
		label.textField.font = Fonts.createSize(CGFloat(DeviceInfo.textFieldFontSize))
		label.placeholder.text = "BIRTHDATE"
		label.isUserInteractionEnabled = false
		
		return label
	}()
	
	let birthdayInfoBig : LeftTextLabel = {
		let label = LeftTextLabel()
		label.label.font = Fonts.createSize(18)
		label.label.text = "Others will not be able to see your birthday"
		label.label.numberOfLines = 2
		label.label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let birthdayInfoSmall : LeftTextLabel = {
		let label = LeftTextLabel()
		label.label.font = Fonts.createLightSize(14.5)
		
		label.label.text = "By entering my birthday, I agree that I'm at least 18 years old."
		label.label.numberOfLines = 2
		label.label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createItalicSize(17)
        label.textColor = .red
        label.isHidden = true
        label.numberOfLines = 2
		label.text = "Must be 18 years or older to use QuickTutor"

        return label
    }()
    
    override func configureView() {
        super.configureView()
		progressBar.progress = 0.8
        progressBar.applyConstraints()
        addSubview(birthdayPicker)
        addSubview(contentView)
        contentView.addSubview(birthdayLabel)
        contentView.addSubview(birthdayInfoBig)
        contentView.addSubview(birthdayInfoSmall)
        contentView.addSubview(errorLabel)
        
        titleLabel.label.text = "We need your birthday"
		
		setupDatePicker()
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        birthdayPicker.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(DeviceInfo.keyboardHeight)
        }
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(birthdayPicker.snp.top)
            make.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        contentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalTo(nextButton.snp.top)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
        }
        birthdayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.47)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        birthdayInfoBig.snp.makeConstraints { make in
            make.top.equalTo(birthdayLabel.snp.bottom)
			make.height.equalTo(35)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        birthdayInfoSmall.snp.makeConstraints { make in
            make.top.equalTo(birthdayInfoBig.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        errorLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(nextButton).inset(4)
            make.right.equalTo(nextButton.snp.left).inset(20)
        }
    }
	private func setupDatePicker() {
		let date = Date()
		birthdayPicker.datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: date)
		birthdayPicker.datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -113, to: date)
		birthdayPicker.datePicker.setDate(date, animated: true)
	}
}

class BirthdayVC: BaseViewController {
    override var contentView: BirthdayView {
        return view as! BirthdayView
    }
    
    override func loadView() {
        view = BirthdayView()
    }
	
	let date = Date()
	let dateformatter = DateFormatter()
	let calendar = Calendar.current
    
    var isFacebookManaged = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        dateformatter.dateFormat = "MMMM d'\(daySuffix(date: date))' yyyy"
        let today = dateformatter.string(from: date)
        contentView.birthdayLabel.textField.text = today
        contentView.birthdayPicker.datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }

    private func checkAgeAndBirthdate() -> Bool {
        let birthdate = contentView.birthdayPicker.datePicker.calendar!
		let birthday = birthdate.dateComponents([.day, .month, .year], from: contentView.birthdayPicker.datePicker.date)
        let age = birthdate.dateComponents([.year], from: contentView.birthdayPicker.datePicker.date, to: date)
		
		guard let yearsOld = age.year, yearsOld >= 18,
			  let day = birthday.day,
			  let month = birthday.month,
			  let year = birthday.year
		else {
			return false
		}
		Registration.age = age.year!
		Registration.dob = String("\(day)/\(month)/\(year)")
		contentView.errorLabel.isHidden = true
		
		return true
    }
	
	override func handleNavigation() {
        if touchStartView == contentView.backButton {
            navigationController!.view.layer.add(contentView.backButton.transition, forKey: nil)
            navigationController!.popViewController(animated: false)
        } else if touchStartView == contentView.nextButton {
			if checkAgeAndBirthdate() {
                proceedToNextScreen()
			} else {
				contentView.errorLabel.isHidden = false
			}
        }
    }
    
    func proceedToNextScreen() {
        if isFacebookManaged {
            let next = UserPolicyVC()
            navigationController?.pushViewController(next, animated: true)
        } else {
            let next = UploadImageVC()
            navigationController!.pushViewController(next, animated: true)
        }
    }
    
    private func daySuffix(date: Date) -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        // show new date on label when its changed.
		dateformatter.dateFormat = "MMMM d'\(daySuffix(date: contentView.birthdayPicker.datePicker.date))' yyyy"
		let date = dateformatter.string(from: contentView.birthdayPicker.datePicker.date)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
