//
//  TutorManagePolicies.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import Foundation
import UIKit

class EditProfilePolicyView: InteractableView {
    let infoLabel: LeftTextLabel = {
        let label = LeftTextLabel()
        label.label.font = Fonts.createBoldSize(15)
        return label
    }()

    let textField: NoPasteTextField = {
        let textField = NoPasteTextField()
        textField.font = Fonts.createSize(18)
        textField.textColor = .white
        textField.textAlignment = .left
        textField.adjustsFontSizeToFitWidth = true
        return textField
    }()

    let sideLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(15)
        label.text = "•"
        return label
    }()

    let divider: BaseView = {
        let view = BaseView()
        view.backgroundColor = Colors.divider
        return view
    }()

    let spacer: BaseView = {
        let view = BaseView()
        return view
    }()

    let label: UILabel = {
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

        infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().inset(3)
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).inset(4)
            make.left.equalToSuperview().inset(3)
            make.right.equalToSuperview()
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).inset(-6)
            make.height.equalTo(30)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
        }

        sideLabel.snp.makeConstraints { make in
            make.right.equalTo(label)
            make.centerY.equalTo(textField)
        }

        divider.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).inset(-5)
            make.height.equalTo(1)
            make.left.equalTo(infoLabel)
            make.right.equalTo(infoLabel)
            make.bottom.equalToSuperview().inset(8)
        }
    }
}

class TutorManagePolicies: UIViewController {
    
    let contentView: TutorManagePoliciesVCView = {
        let view = TutorManagePoliciesVCView()
        return view
    }()

    var ref: DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)

    let pickerView = UIPickerView()
    var tutor: AWTutor!
    var datasource = [String]() {
        didSet {
            pickerView.reloadAllComponents()
        }
    }

    var selectedTextField: UITextField! {
        didSet {
            selectedTextField.inputView = pickerView
            pickerView.selectRow(0, inComponent: 0, animated: true)
        }
    }

    let latePolicy = ["None", "5 Minutes", "10 Minutes", "15 Minutes", "20 Minutes", "25 Minutes", "30 Minutes", "35 Minutes", "40 Minutes", "45 Minutes", "50 Minutes", "55 Minutes", "60 Minutes"]
    let lateFee = ["None", "$5.00", "$10.00", "$15.00", "$20.00", "$25.00", "$30.00", "$35.00", "$40.00", "$45.00", "$50.00"]
    let cancelNotice = ["None", "1 Hour", "2 Hours", "3 Hours", "4 Hours", "5 Hours", "6 Hours", "7 Hours", "8 Hours", "9 Hours", "10 Hours", "11 Hours", "12 Hours", "24 Hours", "36 Hours", "48 Hours", "72 Hours"]
    let cancelFee = ["None", "$5.00", "$10.00", "$15.00", "$20.00", "$25.00", "$30.00", "$35.00", "$40.00", "$45.00", "$50.00", "$55.00", "$60.00", "$65.00", "$70.00", "$75.00", "$80.00", "$85.00", "$90.00", "$95.00", "$100.00"]

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureDelegates()
//        loadTutorPolicy()

        contentView.layoutIfNeeded()
        contentView.scrollView.setContentSize()
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Manage Policies"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"newCheck"), style: .plain, target: self, action: #selector(savePolicies))
    }
    
    override func loadView() {
        view = contentView
    }

    func configureDelegates() {
        pickerView.delegate = self
        pickerView.dataSource = self

        contentView.scrollView.delegate = self
        contentView.latePolicy.textField.delegate = self
        contentView.lateFee.textField.delegate = self
        contentView.cancelNotice.textField.delegate = self
        contentView.cancelFee.textField.delegate = self
    }

    func loadTutorPolicy() {
        guard let tutorPolicy = tutor.policy else {
            return
        }

        let policy = tutorPolicy.split(separator: "_")

        if policy[0] != "0" {
            contentView.latePolicy.textField.text = "\(policy[0]) Minutes"
        }
        if policy[1] != "0" {
            contentView.lateFee.textField.text = "$\(policy[1]).00"
        }
        if policy[2] != "0" {
            contentView.cancelNotice.textField.text = "\(policy[2]) Hours"
        }
        if policy[3] != "0" {
            contentView.cancelFee.textField.text = "$\(policy[3]).00"
        }
        return
    }

    @objc func savePolicies() {
        var latePolicy = contentView.latePolicy.textField.text!

        if latePolicy == "None" || latePolicy == "" {
            latePolicy = "0"
        } else {
            latePolicy = latePolicy.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890").inverted)
        }

        var lateFee = contentView.lateFee.textField.text!

        if lateFee == "None" || lateFee == "" {
            lateFee = "0"
        } else {
            lateFee = lateFee.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted).replacingOccurrences(of: ".00", with: "")
        }

        var cancelNotice = contentView.cancelNotice.textField.text!

        if cancelNotice == "None" || cancelNotice == "" {
            cancelNotice = "0"
        } else {
            cancelNotice = cancelNotice.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890").inverted)
        }

        var cancelFee = contentView.cancelFee.textField.text!

        if cancelFee == "None" || cancelFee == "" {
            cancelFee = "0"
        } else {
            cancelFee = cancelFee.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted).replacingOccurrences(of: ".00", with: "")
        }

        let policyString = "\(latePolicy)_\(lateFee)_\(cancelNotice)_\(cancelFee)"

        Database.database().reference().child("tutor-info").child(CurrentUser.shared.learner.uid!).updateChildValues(["pol": policyString]) { error, _ in
            if let error = error {
                print(error)
            } else {
                self.displaySavedAlertController()
                CurrentUser.shared.tutor.policy = policyString
            }
        }
    }

    @objc private func displaySavedAlertController() {
        let alertController = UIAlertController(title: "Saved!", message: "Your policy changes have been saved", preferredStyle: .alert)

        present(alertController, animated: true, completion: nil)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertController.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension TutorManagePolicies: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
        switch textField {
        case contentView.latePolicy.textField:
            datasource = latePolicy
            pickerView.selectRow(0, inComponent: 0, animated: true)
            contentView.scrollView.setContentOffset(CGPoint(x: 0, y: 50), animated: true)
        case contentView.lateFee.textField:
            datasource = lateFee
            contentView.scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)

        case contentView.cancelNotice.textField:
            datasource = cancelNotice
            contentView.scrollView.setContentOffset(CGPoint(x: 0, y: 150), animated: true)
        case contentView.cancelFee.textField:
            datasource = cancelFee
            contentView.scrollView.setContentOffset(CGPoint(x: 0, y: 175), animated: true)
        default:
            break
        }
    }
}

extension TutorManagePolicies: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_: UIPickerView, attributedTitleForRow row: Int, forComponent _: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: datasource[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: Fonts.createSize(20)])
        return attributedString
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        pickerView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return datasource.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return datasource[row]
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        selectedTextField.text = datasource[row]
    }
}

extension TutorManagePolicies: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_: UIScrollView) {
        view.endEditing(true)
    }
}
