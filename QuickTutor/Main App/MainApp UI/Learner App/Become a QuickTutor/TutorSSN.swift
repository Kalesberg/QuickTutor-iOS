//
//  TutorSSN.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import SnapKit
import UIKit

class SSNDigitTextField: RegistrationDigitTextField {
    override func applyConstraint(rightMultiplier: ConstraintMultiplierTarget) {
        snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25)
            make.right.equalToSuperview().multipliedBy(rightMultiplier)
        }

        textField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalToSuperview()
        }

        line.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(1)
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.centerX.equalToSuperview()
        }
    }
}

class TutorSSNView: TutorRegistrationLayout, Keyboardable {
    var keyboardComponent = ViewComponent()

    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "For authentication purposes, we'll need the last 4 digits of your Social Security Number."
        label.numberOfLines = 0
        label.sizeToFit()
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
        return label
    }()

    var digitView = UIView()

    var digit1 = SSNDigitTextField()
    var digit2 = SSNDigitTextField()
    var digit3 = SSNDigitTextField()
    var digit4 = SSNDigitTextField()

    var lockImageView = UIImageView()
    var ssnInfo = LeftTextLabel()

    override func configureView() {
        addSubview(titleLabel)
        addSubview(digitView)
        addSubview(ssnInfo)
        addKeyboardView()
        digitView.addSubview(digit1)
        digitView.addSubview(digit2)
        digitView.addSubview(digit3)
        digitView.addSubview(digit4)
        super.configureView()

        progressBar.progress = 0.5
        progressBar.applyConstraints()

        title.label.text = "SSN"

        navbar.backgroundColor = Colors.tutorBlue
        statusbarView.backgroundColor = Colors.tutorBlue

        ssnInfo.label.text = "· Your SSN remains private.\n· No credit check - credit won't be affected.\n· Your information is safe and secure."
        ssnInfo.label.font = Fonts.createSize(15)

        lockImageView.image = UIImage(named: "registration-ssn-lock")
    }

    override func applyConstraints() {
        super.applyConstraints()

        titleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.top.equalTo(navbar.snp.bottom).inset(-35)
            make.centerX.equalToSuperview()
        }

        digitView.snp.makeConstraints { make in
            make.width.equalTo(250)
            make.height.equalToSuperview().multipliedBy(0.15)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
        }

        digit1.applyConstraint(rightMultiplier: 0.25)
        digit2.applyConstraint(rightMultiplier: 0.5)
        digit3.applyConstraint(rightMultiplier: 0.75)
        digit4.applyConstraint(rightMultiplier: 1.0)

        ssnInfo.snp.makeConstraints { make in
            make.top.equalTo(digitView.snp.bottom).inset(-30)
            make.width.equalTo(titleLabel)
            make.centerX.equalToSuperview()
        }
    }
}

class TutorSSNVC: BaseViewController {
    override var contentView: TutorSSNView {
        return view as! TutorSSNView
    }

    override func loadView() {
        view = TutorSSNView()
    }

    var index: Int = 0
    var textFields: [UITextField] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        if !(UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
            contentView.digit1.textField.becomeFirstResponder()
        }

        textFields = [contentView.digit1.textField, contentView.digit2.textField, contentView.digit3.textField, contentView.digit4.textField]

        configureTextFields()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // TODO:
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textFields[0].becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func configureTextFields() {
        for textField in textFields {
            textField.delegate = self
            textField.isEnabled = false
        }
        textFields[0].isEnabled = true
    }

    private func textFieldController(current: UITextField, textFieldToChange: UITextField) {
        current.isEnabled = false
        textFieldToChange.isEnabled = true
    }

    override func handleNavigation() {
        if touchStartView is NavbarButtonNext {
            var last4SSN = ""
            textFields.forEach({ last4SSN.append($0.text!) })
            if last4SSN.count == 4 {
                TutorRegistration.last4SSN = last4SSN
                navigationController?.pushViewController(TutorRegPayment(), animated: true)
            } else {
                AlertController.genericErrorAlertWithoutCancel(self, title: "Invalid SSN", message: nil)
            }
        }
    }
}

extension TutorSSNVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")

        let inverseSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        guard string == filtered else { return false }

        if (index == 0) && (isBackSpace == Constants.BCK_SPACE) {
            textFields[index].text = ""
            return true
        } else if isBackSpace == Constants.BCK_SPACE {
            textFields[index].text = ""
            textFieldController(current: textFields[index], textFieldToChange: textFields[index - 1])
            index -= 1
            textFields[index].becomeFirstResponder()
            return false
        }

        if index < 3 {
            if textField.text == "" {
                textField.text = string
                return false
            }
            textFieldController(current: textFields[index], textFieldToChange: textFields[index + 1])
            index += 1
            textFields[index].becomeFirstResponder()
            textFields[index].text = string
            return false
        }
        if index == 3 {
            return (textFields[index].text == "") ? true : false
        }
        return false
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        return false
    }
}
