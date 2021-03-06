//
//  PhoneAuthentication.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

protocol AlertAction {
    func cancelAlertPressed()
    func verifyAlertPressed(code: String)
}

class PhoneAuthenicationAction: InteractableView, Interactable {
    let action: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(20)
        label.textColor = Colors.grayText80
        label.textAlignment = .center

        return label
    }()

    override func configureView() {
        addSubview(action)
        super.configureView()
        applyConstraints()
    }

    override func applyConstraints() {
        action.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupTargets() {
        action.isUserInteractionEnabled = true
        action.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleVerifyButtonClicked)))
    }

    @objc
    func handleVerifyButtonClicked() {
        if let didVerifyButtonClicked = didVerifyButtonClicked {
            didVerifyButtonClicked()
        }
    }
    
    var didVerifyButtonClicked: (() -> ())?
    
    func touchStart() {
        alpha = 0.7
    }

    func didDragOff() {
        alpha = 1.0
    }

    func touchEndOnStart() {
        alpha = 1.0
    }

    func touchEndOffStart() {
        alpha = 1.0
    }
}

class PhoneAuthenicationActionCancel: InteractableView, Interactable {
    let cancel: UILabel = {
        let label = UILabel()
        label.text = "Cancel"
        label.font = Fonts.createBoldSize(20)
        label.textColor = Colors.grayText80
        label.textAlignment = .center

        return label
    }()

    override func configureView() {
        addSubview(cancel)
        super.configureView()

        applyConstraints()
    }

    override func applyConstraints() {
        cancel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    var didCancelButtonClicked: (() -> ())?
    
    func setupTargets() {
        cancel.isUserInteractionEnabled = true
        cancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCancelButtonClicked)))
    }
    
    @objc
    func handleCancelButtonClicked() {
        if let didCancelButtonClicked = didCancelButtonClicked {
            didCancelButtonClicked()
        }
    }
    
    func touchStart() {
        alpha = 0.7
    }

    func didDragOff() {
        alpha = 1.0
    }

    func touchEndOnStart() {
        alpha = 1.0
    }

    func touchEndOffStart() {
        alpha = 1.0
    }
}

class PhoneAuthenticationAlertView: InteractableView {
    var alertView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.7, offset: CGSize(width: -2, height: 2), radius: 5)
        return view
    }()

    let title: UILabel = {
        let label = UILabel()
        label.text = "Phone Verification"
        label.font = Fonts.createBoldSize(22)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let message: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(16)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 3
        return label
    }()

    let errorLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        return label
    }()

    var cancelAction = PhoneAuthenicationActionCancel()
    var verifyAction = PhoneAuthenicationAction()

    let verificationTextField: NoPasteTextField = {
        let textField = NoPasteTextField()
        textField.text = "——————"
        textField.font = Fonts.createBoldSize(35)
        textField.textColor = .white
        textField.tintColor = .black
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = true
        textField.keyboardType = .numberPad
        textField.keyboardAppearance = .dark
        return textField
    }()

    var delegate: AlertAction?

    override func configureView() {
        addSubview(alertView)
        alertView.addSubview(title)
        alertView.addSubview(message)
        alertView.addSubview(errorLabel)
        alertView.addSubview(cancelAction)
        alertView.addSubview(verifyAction)
        alertView.addSubview(verificationTextField)
        super.configureView()

        verifyAction.action.text = "Verify"
        backgroundColor = UIColor.black.withAlphaComponent(0.4)

        verificationTextField.defaultTextAttributes.updateValue(10.0, forKey: NSAttributedString.Key(rawValue: NSAttributedString.Key.kern.rawValue))
        //		convertFromNSAttributedStringKeyDictionary(verificationTextField.defaultTextAttributes).updateValue(10.0, forKey: NSAttributedString.Key.kern.rawValue)

        alpha = 0.0
        configureDelegates()
        applyConstraints()
    }

    override func applyConstraints() {
        alertView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalToSuperview().multipliedBy(0.85)
        }
        title.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        message.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(title.snp.bottom).offset(16)
        }

        cancelAction.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
            make.left.equalToSuperview()
        }
        verifyAction.snp.makeConstraints { make in
            make.size.equalTo(cancelAction.snp.size)
            make.centerY.equalTo(cancelAction.snp.centerY)
            make.left.equalTo(cancelAction.snp.right)
            make.right.equalToSuperview()
        }
        errorLabel.snp.makeConstraints { make in
            make.bottom.equalTo(cancelAction.snp.top).offset(-4)
            make.left.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        verificationTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(message.snp.bottom).offset(8)
            make.bottom.equalTo(errorLabel.snp.top).offset(-8)
        }
    }

    override func layoutSubviews() {
        alertView.layer.cornerRadius = 10
        verifyAction.layer.addBorder(edge: .top, color: .black, thickness: 1.0)
        cancelAction.layer.addBorder(edge: .top, color: .black, thickness: 1.0)
        cancelAction.layer.addBorder(edge: .right, color: .black, thickness: 1.0)
    }

    private func configureDelegates() {
        cancelAction.didCancelButtonClicked = {
            self.delegate?.cancelAlertPressed()
        }
        cancelAction.setupTargets()
        
        verifyAction.didVerifyButtonClicked = {
            self.delegate?.verifyAlertPressed(code: self.verificationTextField.text ?? "")
        }
        verifyAction.setupTargets()
        verificationTextField.delegate = self
    }
}

extension PhoneAuthenticationAlertView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn: "0123456789_").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        guard let text = textField.text else { return false }

        if string == filtered {
            if string == "" {
                guard let indexToReplace = text.index(text.startIndex, offsetBy: range.location, limitedBy: text.endIndex) else { return false }
                textField.text?.remove(at: indexToReplace)
                textField.text?.insert("—", at: indexToReplace)

                if let newPostion = textField.position(from: textField.beginningOfDocument, offset: range.location) {
                    textField.selectedTextRange = textField.textRange(from: newPostion, to: newPostion)
                    return false
                }
            }

            if range.location + 1 <= text.count,
                let end = text.index(text.startIndex, offsetBy: range.location + 1, limitedBy: text.endIndex),
                let start = text.index(text.startIndex, offsetBy: range.location, limitedBy: text.endIndex) {
                textField.text = textField.text?.replacingOccurrences(of: "—", with: string, options: .caseInsensitive, range: Range(uncheckedBounds: (lower: start, upper: end)))
            }
            if range.location + 1 < text.count {
                if let newPosition = textField.position(from: textField.beginningOfDocument, offset: range.location + 1) {
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
            }
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let newPosition = textField.beginningOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
    }
}

extension UIViewController {
    func displayPhoneVerificationAlert(message: String, _ alertAction: AlertAction?) {
        if let _ = self.view.viewWithTag(321) {
            return
        }
        let alert = PhoneAuthenticationAlertView()
        alert.tag = 321
        alert.frame = view.bounds
        alert.message.text = message
        alert.delegate = alertAction

        alert.growShrink()
        alert.verificationTextField.becomeFirstResponder()
        view.addSubview(alert)
    }

    func dismissPhoneAuthenticationAlert() {
        view.endEditing(true)
        if let alert = self.view.viewWithTag(321) {
            UIView.animate(withDuration: 0.2, animations: {
                alert.alpha = 0.0
                alert.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            }) { _ in
                alert.removeFromSuperview()
            }
        }
    }
}
