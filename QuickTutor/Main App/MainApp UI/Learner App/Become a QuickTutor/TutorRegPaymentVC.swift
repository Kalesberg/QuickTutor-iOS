//
//  TutorPaymentInformation.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import SnapKit
import Stripe
import UIKit

class PaymentTextField: NoPasteTextField {
    override func configureTextField() {
        super.configureTextField()

        font = Fonts.createSize(15)
        textColor = Colors.grayText
        autocapitalizationType = .words
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = Colors.learnerPurple.cgColor
    }

    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

class TutorRegPaymentView: TutorRegistrationLayout, Keyboardable {
    var keyboardComponent = ViewComponent()
    var contentView = UIView()
    var nameTitle = SectionTitle()
    var nameTextfield = PaymentTextField()
    var routingNumberTitle = SectionTitle()
    var routingNumberTextfield = PaymentTextField()
    var accountNumberTitle = SectionTitle()
    var accountNumberTextfield = PaymentTextField()

    override func configureView() {
        addSubview(contentView)
        contentView.addSubview(nameTitle)
        contentView.addSubview(nameTextfield)
        contentView.addSubview(routingNumberTitle)
        contentView.addSubview(routingNumberTextfield)
        contentView.addSubview(accountNumberTitle)
        contentView.addSubview(accountNumberTextfield)
        addKeyboardView()
        super.configureView()

        progressBar.progress = 0.666667
        progressBar.applyConstraints()

        title.label.text = "Add Bank"

        nameTitle.label.text = "Account Holder Name"
        routingNumberTitle.label.text = "Routing Number"
        accountNumberTitle.label.text = "Account Number"

        nameTextfield.attributedPlaceholder = NSAttributedString(string: "Enter account holder's name", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
        nameTextfield.keyboardType = .asciiCapable

        routingNumberTextfield.attributedPlaceholder = NSAttributedString(string: "Enter Routing Number", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
        routingNumberTextfield.keyboardType = .decimalPad

        accountNumberTextfield.attributedPlaceholder = NSAttributedString(string: "Enter Account Number", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
        accountNumberTextfield.keyboardType = .decimalPad

        navbar.backgroundColor = Colors.tutorBlue
        statusbarView.backgroundColor = Colors.tutorBlue
    }

    override func applyConstraints() {
        super.applyConstraints()

        contentView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.top.equalTo(navbar.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(keyboardView.snp.top)
        }
        nameTitle.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.18)
            make.centerX.equalToSuperview()
        }
        nameTextfield.snp.makeConstraints { make in
            make.top.equalTo(nameTitle.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        routingNumberTitle.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(nameTextfield.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.18)
        }
        routingNumberTextfield.snp.makeConstraints { make in
            make.top.equalTo(routingNumberTitle.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        accountNumberTitle.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(routingNumberTextfield.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.18)
        }
        accountNumberTextfield.snp.makeConstraints { make in
            make.top.equalTo(accountNumberTitle.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
    }
}

class TutorRegPaymentVC: BaseViewController {
    override var contentView: TutorRegPaymentView {
        return view as! TutorRegPaymentView
    }

    override func loadView() {
        view = TutorRegPaymentView()
    }

    var fullName: String!
    var routingNumber: String!
    var accountNumber: String!
    var validAccountData: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let textFields = [contentView.nameTextfield, contentView.routingNumberTextfield, contentView.accountNumberTextfield]

        for textField in textFields {
            textField.delegate = self
            textField.returnKeyType = .next
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.rightButton.isUserInteractionEnabled = true
        contentView.nameTextfield.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc private func textFieldDidChange(_: UITextField) {
        guard let name = contentView.nameTextfield.text, name.fullNameRegex() else {
            contentView.nameTextfield.layer.borderColor = Colors.qtRed.cgColor
            validAccountData = false
            return
        }
        contentView.nameTextfield.layer.borderColor = Colors.green.cgColor
        guard let routingNumber = contentView.routingNumberTextfield.text, routingNumber.count == 9 else {
            if contentView.routingNumberTextfield.text!.count > 1 {
                contentView.routingNumberTextfield.layer.borderColor = Colors.qtRed.cgColor
            }
            validAccountData = false
            return
        }
        contentView.routingNumberTextfield.layer.borderColor = Colors.green.cgColor
        guard let accountNumber = contentView.accountNumberTextfield.text, accountNumber.count > 5 else {
            if contentView.accountNumberTextfield.text!.count > 1 {
                contentView.accountNumberTextfield.layer.borderColor = Colors.qtRed.cgColor
            }
            validAccountData = false
            return
        }
        contentView.accountNumberTextfield.layer.borderColor = Colors.green.cgColor
        validAccountData = true

        fullName = name
        self.routingNumber = routingNumber
        self.accountNumber = accountNumber
    }

    override func handleNavigation() {
        if touchStartView is NavbarButtonNext {
            contentView.rightButton.isUserInteractionEnabled = false
            if validAccountData {
                dismissOverlay()
                Stripe.createBankAccountToken(accountHoldersName: fullName, routingNumber: routingNumber, accountNumber: accountNumber) { token, _ in
                    if let token = token {
                        TutorRegistration.bankToken = token
                        self.navigationController?.pushViewController(TutorAddressVC(), animated: true)
                    } else {
                        AlertController.genericErrorAlert(self, title: "Bank Account Error", message: "Unable to create bank account. Please verify the information is correct.")
                        self.contentView.rightButton.isUserInteractionEnabled = true
                    }
                    self.dismissOverlay()
                }
            } else {
                contentView.rightButton.isUserInteractionEnabled = true
            }
        }
    }
}

extension TutorRegPaymentVC: UITextFieldDelegate {
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case contentView.nameTextfield:
            contentView.routingNumberTextfield.becomeFirstResponder()
        case contentView.routingNumberTextfield:
            contentView.accountNumberTextfield.becomeFirstResponder()
        case contentView.accountNumberTextfield:
            resignFirstResponder()
        default:
            resignFirstResponder()
        }
        return true
    }

    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length

        switch textField {
        case contentView.nameTextfield:
            if string == "" { return true }
            if newLength <= 20 { return !(string == filtered) }
            return true
        case contentView.routingNumberTextfield:
            return (filtered == string)
        case contentView.accountNumberTextfield:
            return (filtered == string)
        default:
            return false
        }
    }
}
