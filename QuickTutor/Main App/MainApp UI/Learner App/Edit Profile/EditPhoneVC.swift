//
//  EditPhone.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import UIKit

class EditPhoneView: MainLayoutTitleBackButton, Keyboardable {
    var keyboardComponent = ViewComponent()

    var phoneTextField = EditPhoneTextField()
    var subtitle = LeftTextLabel()
    var enterButton = EnterButton()

    override func configureView() {
        addSubview(phoneTextField)
        phoneTextField.addSubview(subtitle)
        addSubview(enterButton)
        addKeyboardView()
        super.configureView()

        title.label.text = "Change Number"

        subtitle.label.text = "Phone Number"
        subtitle.label.font = Fonts.createBoldSize(18)
        subtitle.label.numberOfLines = 2
    }

    override func applyConstraints() {
        super.applyConstraints()

        subtitle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }

        phoneTextField.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerY.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(90)
            make.centerX.equalToSuperview()
        }

        enterButton.snp.makeConstraints { make in
            make.bottom.equalTo(keyboardView.snp.top)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.08)
            make.centerX.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if AccountService.shared.currentUserType == .tutor {
            navbar.backgroundColor = Colors.tutorBlue
            statusbarView.backgroundColor = Colors.tutorBlue
            enterButton.backgroundColor = Colors.tutorBlue
            phoneTextField.textField.tintColor = Colors.tutorBlue
        } else {
            navbar.backgroundColor = Colors.learnerPurple
            statusbarView.backgroundColor = Colors.learnerPurple
            enterButton.backgroundColor = Colors.learnerPurple
            phoneTextField.textField.tintColor = Colors.learnerPurple
        }
    }
}

class EditPhoneTextField: InteractableView, Interactable {
    var textField = NoPasteTextField()
    var flag = UIImageView()
    var plusOneLabel = UILabel()
    var line = UIView()
    var infoLabel = UILabel()

    override func configureView() {
        addSubview(textField)
        addSubview(line)
        addSubview(flag)
        addSubview(plusOneLabel)
        addSubview(infoLabel)

        super.configureView()

        textField.font = Fonts.createSize(22)
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.tintColor = .white
        textField.keyboardType = .numberPad
        textField.isEnabled = true

        flag.image = UIImage(named: "flag")
        flag.scaleImage()

        plusOneLabel.textColor = .white
        plusOneLabel.font = Fonts.createSize(22)
        plusOneLabel.text = "+1"
        plusOneLabel.textAlignment = .center

        line.backgroundColor = .white

        infoLabel.text = "A six digit verification code will be sent to this number."
        infoLabel.textColor = UIColor(red: 0.596234858, green: 0.5957894325, blue: 0.6132271886, alpha: 1)
        infoLabel.font = Fonts.createSize(19)
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.adjustsFontForContentSizeCategory = true

        applyConstraints()
    }

    override func applyConstraints() {
        flag.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalTo(30)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        plusOneLabel.snp.makeConstraints { make in
            make.left.equalTo(flag.snp.right)
            make.bottom.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(flag)
        }

        textField.snp.makeConstraints { make in
            make.left.equalTo(plusOneLabel.snp.right)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.49)
        }

        line.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).multipliedBy(1.01)
            make.width.equalToSuperview()
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
    }
}

class EnterButton: InteractableView, Interactable {
    var title = UILabel()

    override func configureView() {
        addSubview(title)
        super.configureView()

        isUserInteractionEnabled = true

        title.text = "Enter"
        title.textColor = UIColor.white
        title.font = Fonts.createSize(20)
        title.textAlignment = .center
        title.adjustsFontSizeToFitWidth = true

        backgroundColor = UIColor(red: 0.3308961987, green: 0.2544008791, blue: 0.4683592319, alpha: 1)

        applyConstraints()
    }

    override func applyConstraints() {
        title.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
}

class EditPhoneVC: BaseViewController {
    override var contentView: EditPhoneView {
        return view as! EditPhoneView
    }

    override func loadView() {
        view = EditPhoneView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.phoneTextField.textField.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.phoneTextField.textField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func displaySavedAlertController() {
        let alertController = UIAlertController(title: "Saved!", message: "Your changes have been saved", preferredStyle: .alert)

        present(alertController, animated: true, completion: nil)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertController.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func updateNewPhone() {
        let phoneNumber = contentView.phoneTextField.textField.text!.cleanPhoneNumber()

        if phoneNumber.phoneRegex() {
            FirebaseData.manager.updateMobileNumber(phone: phoneNumber, completion: { error in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Unable to Update", message: error.localizedDescription)
                } else {
                    EditPhoneVerificationVC.phoneNumber = phoneNumber.formatPhoneNumber()
                    self.displaySavedAlertController()
                }
            })
        } else {
            AlertController.genericErrorAlert(self, title: "Unable to Verify Phone", message: "")
            contentView.phoneTextField.textField.becomeFirstResponder()
        }
    }

    override func handleNavigation() {
        if touchStartView is EnterButton {
            dismissKeyboard()
            updateNewPhone()
        }
    }
}

extension EditPhoneVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)

        let decimalString = components.joined(separator: "") as NSString
        let length = decimalString.length
        let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)

        if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int

            return (newLength > 10) ? false : true
        }
        var index = 0 as Int
        let formattedString = NSMutableString()

        if hasLeadingOne {
            formattedString.append("1 ")
            index += 1
        }
        if (length - index) > 3 {
            let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("(%@) ", areaCode)
            index += 3
        }
        if length - index > 3 {
            let prefix = decimalString.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", prefix)
            index += 3
        }

        let remainder = decimalString.substring(from: index)
        formattedString.append(remainder)
        textField.text = formattedString as String
        return false
    }
}
