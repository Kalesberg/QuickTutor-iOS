//
//  TutorManagePolicies.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EditProfilePolicyView : InteractableView {
	
	let infoLabel : LeftTextLabel = {
		
		let label = LeftTextLabel()
		
		label.label.font = Fonts.createBoldSize(15)
		
		return label
	}()
	
	let textField : NoPasteTextField =  {
		let textField = NoPasteTextField()
		
		textField.font = Fonts.createSize(18)
		textField.textColor = .white
		textField.textAlignment = .left
		textField.adjustsFontSizeToFitWidth = true
		
		return textField
	}()
	
	let sideLabel : RightTextLabel = {
		let label = RightTextLabel()
		
		return label
	}()
	
	let divider : BaseView = {
		let view = BaseView()
		
		view.backgroundColor = Colors.divider
		
		return view
	}()
	let spacer : BaseView = {
		let view = BaseView()
		
		
		return view
	}()
	
	let label : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createSize(13)
		label.textColor = Colors.grayText
		label.sizeToFit()
		label.numberOfLines = 0
		
		return label
	}()
	
	override func configureView() {
		addSubview(infoLabel)
		addSubview(label)
		addSubview(textField)
		textField.addSubview(sideLabel)
		addSubview(divider)
		addSubview(spacer)
		super.configureView()
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.configureView()
		
		infoLabel.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview().inset(3)
			make.right.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.3)
		}
		
		label.snp.makeConstraints { (make) in
			make.top.equalTo(infoLabel.snp.bottom).inset(4)
			make.left.equalToSuperview().inset(3)
			make.right.equalToSuperview()
		}
		
		textField.snp.makeConstraints { (make) in
			make.top.equalTo(label.snp.bottom).inset(-6)
			make.height.equalTo(30)
			make.left.equalTo(infoLabel)
			make.right.equalTo(infoLabel)
		}
		
		sideLabel.snp.makeConstraints { (make) in
			make.right.equalTo(infoLabel)
			make.height.equalToSuperview()
			make.top.equalToSuperview()
			make.width.equalTo(15)
		}
		
		divider.snp.makeConstraints { (make) in
			make.top.equalTo(textField.snp.bottom).inset(-5)
			make.height.equalTo(1)
			make.left.equalTo(infoLabel)
			make.right.equalTo(infoLabel)
			make.bottom.equalToSuperview().inset(8)
		}
	}
}

class TutorManagePoliciesView : MainLayoutTitleTwoButton {
	
	let scrollView = UIScrollView()
	
	let latePolicy : EditProfilePolicyView = {
		let view = EditProfilePolicyView()
		
		view.infoLabel.label.text = "Late Policy"
		view.textField.attributedPlaceholder = NSAttributedString(string: "Enter how many minutes",
																		attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		view.label.text = "How much time passes from the scheduled session before the learner is late?"
		
		return view
	}()
	
	let lateFee : EditProfilePolicyView = {
		let view = EditProfilePolicyView()
		
		view.infoLabel.label.text = "Late Fee"
		view.textField.attributedPlaceholder = NSAttributedString(string: "Enter a late fee",
																	 attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		view.label.text = "How much a learner pays if they arrive late to a session after the above time."
		
		return view
	}()
	let cancelNotice : EditProfilePolicyView = {
		let view = EditProfilePolicyView()
		
		view.infoLabel.label.text = "Cancellation Notice"
		view.textField.attributedPlaceholder = NSAttributedString(string: "Enter how many hours",
																		  attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		view.label.text = "How many hours before a session should a learner notify you of a cancellation?"
		
		
		return view
		
	}()
	
	let cancelFee : EditProfilePolicyView = {
		let view = EditProfilePolicyView()
		
		view.infoLabel.label.text = "Cancellation Fee"
		view.textField.attributedPlaceholder = NSAttributedString(string: "Enter cancellation fee",
																	   attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		view.label.text = "How much a learner pays if they cancel a session after the above time."
		
		return view
	}()
	
	let subTitle : UILabel = {
		let label = UILabel()
		
		label.text = "Policies"
		
		return label
	}()
	
	var backButton = NavbarButtonBack()
	var saveButton = NavbarButtonSave()
	
	override var leftButton: NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonBack
		}
	}
	override var rightButton: NavbarButton {
		get {
			return saveButton
		} set {
			saveButton = newValue as! NavbarButtonSave
		}
	}
	
	override func configureView() {
		addSubview(scrollView)
		
		scrollView.addSubview(subTitle)
		scrollView.addSubview(latePolicy)
		scrollView.addSubview(lateFee)
		scrollView.addSubview(cancelNotice)
		scrollView.addSubview(cancelFee)
		
		super.configureView()
		
		title.label.text = "Manage Policies"
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		scrollView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.height.equalToSuperview()
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}

		subTitle.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.1)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}

		latePolicy.snp.makeConstraints { (make) in
			make.top.equalTo(subTitle.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.15)
		}
		lateFee.snp.makeConstraints { (make) in
			make.top.equalTo(latePolicy.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.15)
		}
		cancelNotice.snp.makeConstraints { (make) in
			make.top.equalTo(lateFee.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.15)
		}
		cancelFee.snp.makeConstraints { (make) in
			make.top.equalTo(cancelNotice.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.15)
		}
	}
	
	override func layoutSubviews() {
		statusbarView.backgroundColor = Colors.tutorBlue
		navbar.backgroundColor = Colors.tutorBlue

	}
}


class TutorManagePolicies : BaseViewController {
	
	override var contentView: TutorManagePoliciesView {
		return view as! TutorManagePoliciesView
	}
	
	var ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
	
	let pickerView = UIPickerView()
	
	var datasource : [String]? {
		didSet {
			pickerView.reloadAllComponents()
		}
	}
	
	var selectedTextField : UITextField! {
		didSet {
			selectedTextField.inputView = pickerView
		}
	}
	
	let latePolicy = ["None","5 Minutes","10 Minutes","15 Minutes","20 Minutes","25 Minutes","30 Minutes","35 Minutes","40 Minutes","45 Minutes","50 Minutes","55 Minutes","60 Minutes"]
	let lateFee = ["None","$5.00","$10.00","$15.00","$20.00","$25.00","$30.00","$35.00","$40.00","$45.00","$50.00"]
	let cancelNotice = ["None","1 Hour","2 Hours","3 Hours","4 Hours","5 Hours","6 Hours","7 Hours","8 Hours","9 Hours","10 Hours","11 Hours","12 Hours"]
	let cancelFee = ["0","$5.00","$10.00","$15.00","$20.00","$25.00","$30.00","$35.00","$40.00","$45.00","$50.00","$55.00","$60.00","$65.00","$70.00","$75.00","$80.00","$85.00","$90.00","$95.00","$100.00"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		hideKeyboardWhenTappedAround()
		configureDelegates()
		loadTutorPolicy()
		
	}
	
	override func loadView() {
		view = TutorManagePoliciesView()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	private func configureDelegates() {
		pickerView.delegate = self
		pickerView.dataSource = self
		
		contentView.layoutIfNeeded()
		contentView.scrollView.setContentSize()
		
		contentView.latePolicy.textField.delegate = self
		contentView.lateFee.textField.delegate = self
		contentView.cancelNotice.textField.delegate = self
		contentView.cancelFee.textField.delegate = self
	}
	private func loadTutorPolicy() {
		guard let tutorPolicy = TutorData.shared.policy else {
			return
		}
		let policy = tutorPolicy.split(separator: "_")
		contentView.latePolicy.textField.text = "\(policy[0]) Minutes"
		contentView.lateFee.textField.text = "$\(policy[1]).00"
		contentView.cancelNotice.textField.text = "\(policy[2]) Hours"
		contentView.cancelFee.textField.text = "$\(policy[3]).00"
	}
	private func savePolicies() {
		
		let latePolicy = contentView.latePolicy.textField.text!.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890").inverted)
		let lateFee = contentView.lateFee.textField.text!.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted).replacingOccurrences(of: ".00", with: "")
	
		let canceNotice = contentView.cancelNotice.textField.text!.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890").inverted)
		let cancelFee = contentView.cancelFee.textField.text!.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted).replacingOccurrences(of: ".00", with: "")

		let policyString = "\(latePolicy)_\(lateFee)_\(canceNotice)_\(cancelFee)"
		
		self.ref.child("tutor-info").child(Auth.auth().currentUser!.uid).updateChildValues(["pol" : policyString]) { (error, _) in
			if let error = error {
				print(error)
			} else {
				self.displaySavedAlertController()
				TutorData.shared.policy = policyString
			}
		}
	}
	private func displaySavedAlertController() {
		let alertController = UIAlertController(title: "Saved!", message: "Your policy changes have been saved", preferredStyle: .alert)
		
		self.present(alertController, animated: true, completion: nil)
		
		let when = DispatchTime.now() + 1
		DispatchQueue.main.asyncAfter(deadline: when){
			alertController.dismiss(animated: true){
				self.navigationController?.popViewController(animated: true)
			}
		}
		
	}
	override func handleNavigation() {
		if touchStartView is NavbarButtonSave {
			savePolicies()
		}
	}
}
extension TutorManagePolicies : UITextFieldDelegate {
	
	internal func textFieldDidBeginEditing(_ textField: UITextField) {
		
		selectedTextField = textField

		switch textField {
			
		case contentView.latePolicy.textField:
			self.datasource = self.latePolicy
			
		case contentView.lateFee.textField:
			datasource = lateFee
			
		case contentView.cancelNotice.textField:
			datasource = cancelNotice
			
		case contentView.cancelFee.textField:
			datasource = cancelFee
			
		default:
			break
		}
	}
}

extension TutorManagePolicies : UIPickerViewDelegate, UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return datasource?.count ?? 0
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return datasource?[row]
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedTextField.text = datasource![row]
	}
}
