//
//  TutorSSNViewController.swift
//  QuickTutor
//
//  Created by Will Saults on 4/29/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

enum SSNTextFieldTag: Int {
    case areaNumber, groupNumber, serialNumber
}

class TutorSSNViewController: BaseRegistrationController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var ssnAreaNumberTextField: BorderedTextField!
    @IBOutlet weak var ssnGroupNumberTextField: BorderedTextField!
    @IBOutlet weak var ssnSerialNumberTextField: BorderedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ssnAccessoryView.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
        setupTargets()
        hideKeyboardWhenTappedAround()
        progressView.setProgress(3/6)
        
        let attributedString = NSMutableAttributedString(string: "For authentication and safety purposes, we’ll need your social security number.")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        infoLabel.attributedText = attributedString
        setupTextFields()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + RegistrationSSNModal.INITIAL_DELAY) {
            self.showTrustModal()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)
    }
    
    func setupTargets() {
        nextButton(isEnabled: false)
        ssnAccessoryView.nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        ssnAccessoryView.infoButton.addTarget(self, action: #selector(showTrustModal), for: .touchUpInside)
        ssnAccessoryView.infoTextButton.addTarget(self, action: #selector(showTrustModal), for: .touchUpInside)
    }
    
    func nextButton(isEnabled: Bool) {
        ssnAccessoryView.nextButton.isEnabled = isEnabled
        ssnAccessoryView.nextButton.backgroundColor = isEnabled ? Colors.purple : Colors.gray
    }
    
    func setupTextFields() {
        ssnAreaNumberTextField.becomeFirstResponder()
        ssnAreaNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        ssnGroupNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        ssnSerialNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        ssnAreaNumberTextField.inputAccessoryView = ssnAccessoryView
        ssnGroupNumberTextField.inputAccessoryView = ssnAccessoryView
        ssnSerialNumberTextField.inputAccessoryView = ssnAccessoryView
    }
    
    let ssnAccessoryView: SSNRegistrationAccessoryView = {
        let view = SSNRegistrationAccessoryView()
        return view
    }()
    
    @objc func showTrustModal() {
        let _ = RegistrationSSNModal.view
    }
    
    @objc func handleNext() {
        if checkForValidSSN() {
            TutorRegistration.ssn = ssnText(formatted: false) ?? ""
            navigationController?.pushViewController(TutorAddressVC(), animated: true)
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        let length = textField.text?.utf16.count
        var maxLength = 3
        var nextField: BorderedTextField?
        if let ssnTag = SSNTextFieldTag(rawValue: textField.tag) {
            switch ssnTag {
            case .groupNumber:
                maxLength = 2
                nextField = ssnSerialNumberTextField
            case .serialNumber:
                maxLength = 4
            default:
                maxLength = 3
                nextField = ssnGroupNumberTextField
            }
        }
        
        if let nextField = nextField, length == maxLength {
            nextField.becomeFirstResponder()
        }
        
        nextButton(isEnabled: checkForValidSSN())
    }
    
    func checkForValidSSN() -> Bool {
        return isValidSSN(ssnText(formatted: true) ?? "")
    }
    
    func ssnText(formatted: Bool) -> String? {
        guard let area = ssnAreaNumberTextField?.text, let group = ssnGroupNumberTextField?.text, let serial = ssnSerialNumberTextField?.text else {
            return nil
        }
        
        let delimiter = formatted ? "-" : ""
        return "\(area)\(delimiter)\(group)\(delimiter)\(serial)"
    }
    
    func isValidSSN(_ ssn: String) -> Bool {
        let ssnRegext = "^(?!(000|666|9))\\d{3}-(?!00)\\d{2}-(?!0000)\\d{4}$"
        return ssn.range(of: ssnRegext, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

extension TutorSSNViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        guard let text = textField.text else { return true }
        let newLength = text.utf16.count + string.utf16.count - range.length

        var maxLength = 3
        if let ssnTag = SSNTextFieldTag(rawValue: textField.tag) {
            switch ssnTag {
            case .groupNumber:
                maxLength = 2
            case .serialNumber:
                maxLength = 4
            default:
                maxLength = 3
            }
        }
        
        return string == filtered && newLength <= maxLength
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
}

@IBDesignable
class BorderedTextField: NoPasteTextField {
    @IBInspectable var borderColor: UIColor = Colors.qtRed {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var placeHolderColor: UIColor? {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeHolderColor ?? UIColor.white])
        }
    }
}

class SSNRegistrationAccessoryView: RegistrationAccessoryView {
    
    let infoButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "infoIcon")
        let tintedImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = Colors.purple
        return button
    }()
    
    let infoTextButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.darkBackground
        button.titleLabel?.font = Fonts.createSemiBoldSize(16)
        button.setTitle("Info", for: .normal)
        button.setTitleColor(Colors.purple, for: .normal)
        button.setTitleColor(Colors.selectedPurple, for: .highlighted)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupViews() {
        super.setupViews()
        setupInfoButton()
        setupInfoTextButton()
        layoutIfNeeded()
    }
    
    override func setupMainView() {
        super.setupMainView()
        backgroundColor = Colors.newScreenBackground
    }
    
    override func setupNextButton() {
        addSubview(nextButton)
        nextButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 30, width: 0, height: 0)
        nextButtonWidthAnchor = nextButton.widthAnchor.constraint(equalToConstant: 120)
        nextButtonWidthAnchor?.isActive = true
    }
    
    func setupInfoButton() {
        addSubview(infoButton)
        infoButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 18, paddingLeft: 30, paddingBottom: 18, paddingRight: 0, width: 40, height: 40)
    }
    
    func setupInfoTextButton() {
        addSubview(infoTextButton)
        infoTextButton.anchor(top: nil, left: infoButton.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 18, paddingLeft: 0, paddingBottom: 18, paddingRight: 0, width: 35, height: 40)
    }
}
