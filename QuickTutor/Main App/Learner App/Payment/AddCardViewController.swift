//
//  AddCardViewController.swift
//  QuickTutor
//
//  Created by Will Saults on 5/28/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import CardScan
import Stripe

protocol AddCardViewControllerDelegate: class {
    func addCardViewControllerDidCancel()
    func addCardViewControllerDidCreateToken(token: STPToken)
}

class AddCardViewController: UIViewController {
    
    weak var delegate: AddCardViewControllerDelegate?
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardNumberTextField: CardNumberTextField!
    @IBOutlet weak var expirationTextField: CardExpirationTextField!
    @IBOutlet weak var cvvTextField: CardCVVTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var cardScanButton: UIButton!
    @IBOutlet weak var expiryInfoButton: UIButton!
    @IBOutlet weak var cvvInfoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet var saveButtonBottomConstraint: NSLayoutConstraint!
    
    private var card = STPCardParams()
    private var brand: STPCardBrand?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupDelegates()
        setupTargets()
        hideCardScanButtonIfNeeded()
        setButtonTint()
        setAllTextPlaceholderColor()
        setupKeyboardObservers()
        
        if let cardNumber = cardNumberTextField?.cardNumberWithoutSpaces() {
            let cardBrand = brandForCardNumber(cardNumber)
            updateCardImageForBrand(cardBrand)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardNumberTextField?.becomeFirstResponder()
    }
    
    func setupNavigation() {
        navigationItem.title = "Add card"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = Colors.navBarColor
        
        let image = UIImage(named: "closeCircle")?.withRenderingMode(.alwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissView))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    func setupDelegates() {
        cardNumberTextField?.delegate = self;
        expirationTextField?.delegate = self;
        cvvTextField?.delegate = self;
    }
    
    func setupTargets() {
        cardNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        expirationTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        cvvTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func setupKeyboardObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            saveButtonBottomConstraint.constant = 0
        } else {
            var keyboardHeight = keyboardViewEndFrame.height
            if #available(iOS 11.0, *) {
                keyboardHeight -= UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
            }
            saveButtonBottomConstraint.constant = -keyboardHeight
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideCardScanButtonIfNeeded() {
        if !ScanViewController.isCompatible() {
            self.cardScanButton.isHidden = true
        }
    }
    
    func updateCardBrandForTextField(_ textField: CardNumberTextField) {
        let cardBrand = brandForCardNumber(textField.cardNumberWithoutSpaces())
        updateCardImageForBrand(cardBrand)
        updateCardCVVLengthForBrand(cardBrand)
        
        let lengths = cardNumberLengthsForBrand(cardBrand)
        if let max = lengths.max() {
            textField.maxCardNumberLength = max
        }
    }
    
    func brandForCardNumber(_ cardNumber: String) -> STPCardBrand {
        return STPCardValidator.brand(forNumber: cardNumber)
    }
    
    func updateCardImageForBrand(_ brand: STPCardBrand) {
        cardImage.image = STPImageLibrary.brandImage(for: brand)
    }
    
    func updateCardCVVLengthForBrand(_ brand: STPCardBrand) {
        cvvTextField.cvvLength = brand == .amex ? 4 : 3
    }
    
    func cardNumberLengthsForBrand(_ brand: STPCardBrand) -> [Int] {
        var lengths = [Int]()
        for length in STPCardValidator.lengths(for: brand) {
            lengths.append(Int(truncating: length))
        }
        return lengths
    }
    
    func setAllTextPlaceholderColor() {
        setPlaceholderColorForTextField(cardNumberTextField)
        setPlaceholderColorForTextField(expirationTextField)
        setPlaceholderColorForTextField(cvvTextField)
    }
    
    func setPlaceholderColorForTextField(_ textField: UITextField?) {
        textField?.attributedPlaceholder = NSAttributedString(string: textField?.placeholder ?? "", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.50)])
    }
    
    func setButtonTint() {
        let image = UIImage(named: "informationIcon")?.withRenderingMode(.alwaysTemplate)
        expiryInfoButton?.setImage(image, for: .normal)
        expiryInfoButton?.tintColor = Colors.purple
        cvvInfoButton?.setImage(image, for: .normal)
        cvvInfoButton?.tintColor = Colors.purple
        saveButton.setupTargets()
    }
    
    @IBAction func hideKeyboard() {
        if let textField = cardNumberTextField, textField.isFirstResponder {
            textField.resignFirstResponder()
        } else if let textField = expirationTextField, textField.isFirstResponder {
            textField.resignFirstResponder()
        } else if let textField =  cvvTextField, textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func showCardScanner() {
        guard let vc = ScanViewController.createViewController(withDelegate: self) else {
            return
        }
        
        self.present(vc, animated: true)
    }
    
    func isCardBrandValid(cardNumber: String, cardBrand: STPCardBrand) -> Bool {
        let lengths = cardNumberLengthsForBrand(cardBrand)
        let count = cardNumber.count
        guard let min = lengths.min(), let max = lengths.max(), count >= min && count <= max,
            STPCardValidator.validationState(forNumber: cardNumber, validatingCardBrand: true) == .valid
            else {
                return false
        }
        return true
    }
    
    func isExpirationDateValid(cardBrand: STPCardBrand) -> Bool {
        guard let expDate = expirationTextField?.text, expDate.count == 5, STPCardValidator.validationState(forExpirationYear: String(expDate.suffix(2)), inMonth: String(expDate.prefix(2))) == .valid else {
            errorLabel.isHidden = false
            return false
        }
        
        guard let month = UInt(expDate.prefix(2)), let year = UInt(expDate.suffix(2)) else {
            errorLabel.isHidden = false
            return false
        }
        
        card.expMonth = month
        card.expYear = year
        return true
    }
    
    func isCVVValid(cardBrand: STPCardBrand) -> Bool {
        guard let cvv = cvvTextField?.text, STPCardValidator.validationState(forCVC: cvv, cardBrand: cardBrand) == .valid else {
            return false
        }
        card.cvc = cvv
        return true
    }
    
    func createToken() {
        STPAPIClient.shared().createToken(withCard: card) { (token: STPToken?, error: Error?) in
            guard let token = token, error == nil else {
                self.errorLabel.isHidden = false
                return
            }
            
            self.delegate?.addCardViewControllerDidCreateToken(token: token)
        }
    }
    
    @IBAction func validateAndCreateStripeToken() {
        card.number = cardNumberTextField?.cardNumberWithoutSpaces()
        
        guard let cardNumber = card.number else {
            errorLabel.isHidden = false
            return
        }
        
        let cardBrand = STPCardValidator.brand(forNumber: cardNumber)
        guard isCardBrandValid(cardNumber: cardNumber, cardBrand: cardBrand) else {
            errorLabel.isHidden = false
            return
        }
        
        guard isCVVValid(cardBrand: cardBrand) else {
            errorLabel.isHidden = false
            return
        }
        
        guard isExpirationDateValid(cardBrand: cardBrand) else {
            errorLabel.isHidden = false
            return
        }
        
        createToken()
    }
    
    @IBAction func showExpirationInfo(_ sender: Any) {
        let _ = ExpirationDateModal.view
    }
    
    @IBAction func showCVVInfo(_ sender: Any) {
        let _ = CVVModal.view
    }
    
    @objc func dismissView(_ sender: Any) {
        delegate?.addCardViewControllerDidCancel()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let textField = textField as? CardNumberTextField {
            let cardNumber = textField.cardNumberWithoutSpaces()
            if cardNumber.count == textField.maxCardNumberLength {
                expirationTextField?.becomeFirstResponder()
            }
        } else if let textField = textField as? CardExpirationTextField {
            if textField.text?.count == textField.expirationLength {
                cvvTextField?.becomeFirstResponder()
            }
        } else if let textField = textField as? CardCVVTextField {
            if textField.text?.count == textField.cvvLength {
                cvvTextField?.endEditing(true)
            }
        }
    }
}

extension AddCardViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        errorLabel?.isHidden = true
        
        let inverseSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")
        
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if let textField = textField as? CardNumberTextField {
            textField.updateWithTextField(textField)
            updateCardBrandForTextField(textField)
        } else if let textField = textField as? CardExpirationTextField {
            if newLength <= textField.expirationLength {
                if text.count == 2 && !string.isEmpty {
                    textField.text?.append("/")
                }
                return string == filtered
            } else {
                textField.endEditing(true)
                return false
            }
        } else if let textField = textField as? CardCVVTextField {
            if newLength <= textField.cvvLength {
                return string == filtered
            } else {
                textField.endEditing(true)
                return false
            }
        }
        
        return true
    }
}

extension AddCardViewController: ScanDelegate {
    func userDidSkip(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }
    
    func userDidCancel(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }
    
    func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {
        cardNumberTextField.setText(text: creditCard.number)
        updateCardBrandForTextField(cardNumberTextField)
        
        if var expiryMonth = creditCard.expiryMonth, let expiryYear = creditCard.expiryYear {
            if expiryMonth.count == 1 {
                expiryMonth = "0\(expiryMonth)"
            }
            expirationTextField?.text = "\(expiryMonth)/\(expiryYear.suffix(2))"
            cvvTextField?.becomeFirstResponder()
        } else {
            expirationTextField?.becomeFirstResponder()
        }
        
        self.dismiss(animated: true)
    }
}

class CardNumberTextField: UITextField {
    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
    var maxCardNumberLength = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTextField()
    }
    
    func configureTextField() {
        self.addTarget(self, action: #selector(reformat), for: .editingChanged)
    }
    
    func updateWithTextField(_ textField: UITextField) {
        previousTextFieldContent = textField.text;
        previousSelection = textField.selectedTextRange;
    }
    
    func setText(text: String) {
        var targetCursorPosition = 0
        let cardNumberWithSpaces = self.insertCreditCardSpaces(text, preserveCursorPosition: &targetCursorPosition)
        self.text = cardNumberWithSpaces
    }
    
    func cardNumberWithoutSpaces() -> String {
        var cardNumberWithoutSpaces = ""
        if let text = self.text {
            var targetCursorPosition = 0
            cardNumberWithoutSpaces = self.removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }
        return cardNumberWithoutSpaces
    }
    
    @objc func reformat(textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }
        
        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = self.removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }
        
        if cardNumberWithoutSpaces.count > 19 {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        }
        
        let cardNumberWithSpaces = self.insertCreditCardSpaces(cardNumberWithoutSpaces, preserveCursorPosition: &targetCursorPosition)
        textField.text = cardNumberWithSpaces
        
        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
    }
    
    func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition
        
        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            }
            else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }
        
        return digitsOnlyString
    }
    
    func insertCreditCardSpaces(_ string: String, preserveCursorPosition cursorPosition: inout Int) -> String {
        // Mapping of card prefix to pattern is taken from
        // https://baymard.com/checkout-usability/credit-card-patterns
        
        // UATP cards have 4-5-6 (XXXX-XXXXX-XXXXXX) format
        let is456 = string.hasPrefix("1")
        
        // These prefixes reliably indicate either a 4-6-5 or 4-6-4 card. We treat all these
        // as 4-6-5-4 to err on the side of always letting the user type more digits.
        let is465 = [
            // Amex
            "34", "37",
            
            // Diners Club
            "300", "301", "302", "303", "304", "305", "309", "36", "38", "39"
            ].contains { string.hasPrefix($0) }
        
        // In all other cases, assume 4-4-4-4-3.
        // This won't always be correct; for instance, Maestro has 4-4-5 cards according
        // to https://baymard.com/checkout-usability/credit-card-patterns, but I don't
        // know what prefixes identify particular formats.
        let is4444 = !(is456 || is465)
        
        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition
        
        for i in 0..<string.count {
            let needs465Spacing = (is465 && (i == 4 || i == 10 || i == 15))
            let needs456Spacing = (is456 && (i == 4 || i == 9 || i == 15))
            let needs4444Spacing = (is4444 && i > 0 && (i % 4) == 0)
            
            if needs465Spacing || needs456Spacing || needs4444Spacing {
                stringWithAddedSpaces.append(" ")
                
                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
            
            let characterToAdd = string[string.index(string.startIndex, offsetBy:i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        
        return stringWithAddedSpaces
    }
}

class CardExpirationTextField: UITextField {
    var expirationLength = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class CardCVVTextField: UITextField {
    var cvvLength = 3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
