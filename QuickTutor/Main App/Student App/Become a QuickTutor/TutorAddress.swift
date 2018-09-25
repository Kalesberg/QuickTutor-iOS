//
import SnapKit
//  TutorAddress.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/20/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
import UIKit

fileprivate class SubmitAddressButton: InteractableView, Interactable {
    var label = UILabel()

    override func configureView() {
        addSubview(label)
        super.configureView()

        layer.cornerRadius = 6
        layer.borderWidth = 1.5
        layer.borderColor = Colors.green.cgColor

        label.textColor = Colors.green
        label.text = "Submit Billing Address"
        label.textAlignment = .center
        label.font = Fonts.createSize(18)

        alpha = 0.5

        isUserInteractionEnabled = false

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func touchStart() {
        backgroundColor = Colors.registrationDark
    }

    func didDragOff() {
        backgroundColor = .clear
    }
}

fileprivate class AddressTextField: NoPasteTextField {
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
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}

class TutorAddressView: MainLayoutTitleBackButton, Keyboardable {
    var keyboardComponent = ViewComponent()
    var contentView = UIView()

    var addressLine1Title = SectionTitle()
    fileprivate var addressLine1TextField = AddressTextField()

    var cityTitle = SectionTitle()
    fileprivate var cityTextField = AddressTextField()

    var stateTitle = SectionTitle()
    fileprivate var stateTextField = AddressTextField()

    var zipTitle = SectionTitle()
    fileprivate var zipTextField = AddressTextField()

    fileprivate var submitAddressButton = SubmitAddressButton()

    override func configureView() {
        addSubview(contentView)
        addSubview(submitAddressButton)
        contentView.addSubview(addressLine1Title)
        contentView.addSubview(addressLine1TextField)
        contentView.addSubview(cityTitle)
        contentView.addSubview(cityTextField)
        contentView.addSubview(stateTitle)
        contentView.addSubview(stateTextField)
        contentView.addSubview(zipTitle)
        contentView.addSubview(zipTextField)

        addKeyboardView()
        super.configureView()

        title.label.text = "Billing Address"

        addressLine1Title.label.text = "Address"
        cityTitle.label.text = "City"
        stateTitle.label.text = "State"
        zipTitle.label.text = "Postal Code"

        addressLine1TextField.attributedPlaceholder = NSAttributedString(string: "Enter Billing Address", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        addressLine1TextField.keyboardType = .asciiCapable

        cityTextField.attributedPlaceholder = NSAttributedString(string: "Enter City", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        cityTextField.keyboardType = .asciiCapable

        stateTextField.attributedPlaceholder = NSAttributedString(string: "Enter State", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        stateTextField.keyboardType = .asciiCapable
        stateTextField.autocapitalizationType = .allCharacters

        zipTextField.attributedPlaceholder = NSAttributedString(string: "Enter Postal Code", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
        zipTextField.keyboardType = .decimalPad
    }

    override func applyConstraints() {
        super.applyConstraints()

        submitAddressButton.snp.makeConstraints { make in
            make.bottom.equalTo(keyboardView.snp.top).inset(-10)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.85)
            make.top.equalTo(navbar.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(submitAddressButton.snp.top)
        }

        addressLine1Title.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.18)
            make.centerX.equalToSuperview()
        }

        addressLine1TextField.snp.makeConstraints { make in
            make.top.equalTo(addressLine1Title.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }

        cityTitle.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(addressLine1TextField.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.18)
        }

        cityTextField.snp.makeConstraints { make in
            make.top.equalTo(cityTitle.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }

        stateTitle.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(2)
            make.top.equalTo(cityTextField.snp.bottom)
            make.left.equalTo(cityTitle.snp.left)
            make.height.equalToSuperview().multipliedBy(0.18)
        }

        stateTextField.snp.makeConstraints { make in
            make.top.equalTo(stateTitle.snp.bottom)
            make.width.equalToSuperview().dividedBy(2)
            make.left.equalTo(cityTextField.snp.left)
            make.height.equalTo(30)
        }
        zipTitle.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(2)
            make.top.equalTo(cityTextField.snp.bottom)
            make.right.equalTo(cityTitle.snp.right)
            make.height.equalToSuperview().multipliedBy(0.18)
        }

        zipTextField.snp.makeConstraints { make in
            make.top.equalTo(zipTitle.snp.bottom)
            make.width.equalToSuperview().dividedBy(2)
            make.right.equalTo(cityTextField.snp.right)
            make.height.equalTo(30)
        }
    }
}

class TutorAddress: BaseViewController {
    override var contentView: TutorAddressView {
        return view as! TutorAddressView
    }

    override func loadView() {
        view = TutorAddressView()
    }

    private var textFields: [UITextField] = []
    private var addressString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        textFields = [contentView.addressLine1TextField, contentView.cityTextField, contentView.stateTextField, contentView.zipTextField]

        for textField in textFields {
            textField.delegate = self
            textField.returnKeyType = .next
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        contentView.submitAddressButton.isUserInteractionEnabled = false
        guard let line1 = textFields[0].text, line1.count > 5 else {
            print("invalid line1")
            return
        }
        guard let city = textFields[1].text, city.count >= 2 else {
            print("invalid city")
            return
        }
        guard let state = textFields[2].text, state.count == 2 else {
            print("invalid state")
            return
        }
        guard let zipcode = textFields[3].text, zipcode.count == 5 else {
            print("invalid zip")
            return
        }
        print("Valid info")
        addressString = line1 + " " + city + state + ", " + zipcode
        contentView.submitAddressButton.isUserInteractionEnabled = true
    }

    override func handleNavigation() {
        if touchStartView is SubmitAddressButton {
            _ = TutorLocation(addressString: addressString, completion: { error in
                if let error = error {
                    print(error)
                } else {
                    self.navigationController?.pushViewController(TutorPolicy(), animated: true)
                }
            })
        }
    }
}

extension TutorAddress: UITextFieldDelegate {
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length

        switch textField {
        case textFields[0]:
            if newLength < 30 {
                return true
            }
            return false
        case textFields[1]:
            if string == "" { return true }
            return !(string == filtered)
        case textFields[2]:
            if string == "" { return true }
            if newLength > 2 {
                return false
            } else {
                return !(string == filtered)
            }
        case textFields[3]:
            if newLength <= 6 {
                return string == filtered
            }
            return false
        default:
            break
        }
        return false
    }

    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case textFields[0]:
            textFields[1].becomeFirstResponder()
        case textFields[1]:
            textFields[2].becomeFirstResponder()
        case textFields[2]:
            textFields[3].becomeFirstResponder()
        default:
            break
        }
        return false
    }
}
