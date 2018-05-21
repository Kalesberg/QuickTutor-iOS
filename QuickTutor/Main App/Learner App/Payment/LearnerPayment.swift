//
//  Payment.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import UIKit
import Stripe

class LearnerPaymentView : MainLayoutTitleBackButton, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    
    var subtitleLabel = LeftTextLabel()
    
    fileprivate var frontOfCard = FrontOfCard()
    fileprivate var backOfCard = BackOfCard()
    fileprivate var nextButton = AddNewCard()
    fileprivate var flipToFront = FlipToFront()
    
    override func configureView() {
        addSubview(subtitleLabel)
        addSubview(frontOfCard)
        addSubview(backOfCard)
        addSubview(nextButton)
        addSubview(flipToFront)
        addKeyboardView()
        super.configureView()
        
        title.label.text = "Payment"
        
        subtitleLabel.label.text = "Enter Your Card Number"
        subtitleLabel.label.font = Fonts.createBoldSize(20)
        
        backOfCard.isHidden = true
        backOfCard.backgroundColor = UIColor.clear
        backOfCard.layer.cornerRadius = 6
        
        nextButton.alpha = 0.4
        
        applyConstraints()
    }
    override func applyConstraints() {
        super.applyConstraints()
        frontOfCard.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.24)
            make.centerX.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom)
        }
        backOfCard.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.24)
            make.centerX.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom)
        }
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.08)
            make.centerX.equalToSuperview()
        }
        nextButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(keyboardView.snp.top)
            make.height.equalToSuperview().multipliedBy(0.08)
            make.right.equalToSuperview().inset(20)
            make.width.equalTo(90)
        }
        flipToFront.snp.makeConstraints { (make) in
            make.height.equalTo(nextButton)
            make.left.equalToSuperview().inset(20)
            make.centerY.equalTo(nextButton)
        }
    }
    
    fileprivate func brandDidSwitch() {
        frontOfCard.second4.text = ""
        frontOfCard.third4.text = ""
        frontOfCard.forth4.text = ""
    }
    
    fileprivate func defaultLayout() {
        frontOfCard.forth4.isHidden = false
        
        frontOfCard.second4.attributedPlaceholder = NSAttributedString(string: "XXXX", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        frontOfCard.third4.attributedPlaceholder = NSAttributedString(string: "XXXX", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        frontOfCard.forth4.attributedPlaceholder = NSAttributedString(string: "XXXX", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        backOfCard.CVC.attributedPlaceholder = NSAttributedString(string: "XXX", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
    }
    fileprivate func layoutAmexCard() {
        frontOfCard.forth4.isHidden = true
        frontOfCard.forth4.text = ""
        frontOfCard.second4.attributedPlaceholder = NSAttributedString(string: "XXXXXX", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        frontOfCard.third4.attributedPlaceholder = NSAttributedString(string: "XXXXX", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        backOfCard.CVC.attributedPlaceholder = NSAttributedString(string: "XXXX", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
    }
    fileprivate func layoutDinersCard(){
        frontOfCard.forth4.isHidden = false
        frontOfCard.second4.attributedPlaceholder = NSAttributedString(string: "XXXX", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        frontOfCard.third4.attributedPlaceholder = NSAttributedString(string: "XXXX", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        frontOfCard.forth4.attributedPlaceholder = NSAttributedString(string: "XX", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        applyConstraints()
    }
    fileprivate func isCardNumberValid(_ bool: Bool) {
        frontOfCard.first4.textColor = bool ? .white : UIColor.red
        frontOfCard.second4.textColor = bool ? .white : UIColor.red
        frontOfCard.third4.textColor = bool ? .white : UIColor.red
        frontOfCard.forth4.textColor = bool ? .white : UIColor.red
    }
    fileprivate func invalidInformation(){
        nextButton.isUserInteractionEnabled = false
        nextButton.alpha = 0.4
        nextButton.title.textColor.withAlphaComponent(0.4)
    }
}

fileprivate class FlipToFront : InteractableView, Interactable {
    
    var label = UILabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        label.text = "« Back to Front"
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}

fileprivate class BackOfCard : InteractableView, Interactable {
    
    var contents = UIView()
    
    var CVC = CVCTextField()
    var scanCode = UIView()
    var greyStrip = UIView()
    var smallLittleRandomAssBox = UIView()
    
    override func configureView() {
        addSubview(contents)
        contents.addSubview(scanCode)
        contents.addSubview(greyStrip)
        contents.addSubview(smallLittleRandomAssBox)
        contents.addSubview(CVC)
        super.configureView()
        
        scanCode.backgroundColor = UIColor(red: 0.3019312322, green: 0.3019797206, blue: 0.3019206524, alpha: 1)
        scanCode.layer.cornerRadius = 2
        
        greyStrip.backgroundColor = UIColor(red: 0.3019312322, green: 0.3019797206, blue: 0.3019206524, alpha: 1)
        greyStrip.layer.cornerRadius = 2
        
        smallLittleRandomAssBox.backgroundColor = UIColor(red: 0.3019312322, green: 0.3019797206, blue: 0.3019206524, alpha: 1)
        smallLittleRandomAssBox.layer.cornerRadius = 2
        
        applyConstraints()
    }
    override func applyConstraints() {
        
        contents.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.84)
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        scanCode.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        greyStrip.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(scanCode.snp.bottom).multipliedBy(1.6)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        CVC.snp.makeConstraints { (make) in
            make.left.equalTo(greyStrip.snp.right).inset(2)
            make.top.equalTo(greyStrip.snp.top)
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        smallLittleRandomAssBox.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(greyStrip.frame.height)
            make.height.equalToSuperview().multipliedBy(0.2)
        }
    }
}

fileprivate class FrontOfCard : InteractableView, Interactable {
    
    var frontOfCardContents = UIView()
    var brandBox = UIImageView()
    var cardNumberLabel = LeftTextLabel()
    
    var cardNumberContainer = UIView()
    var first4 = CreditCardNumberTextField()
    var second4 = CreditCardNumberTextField()
    var third4 = CreditCardNumberTextField()
    var forth4 = CreditCardNumberTextField()
    
    var cardholderNameLabel = LeftTextLabel()
    var fullName = FullNameTextField()
    
    var expirationLabel = RightTextLabel()
    var expirationDate = ExpDateTextField()
    
    override func configureView() {
        addSubview(frontOfCardContents)
        
        frontOfCardContents.addSubview(brandBox)
        frontOfCardContents.addSubview(cardNumberLabel)
        frontOfCardContents.addSubview(cardNumberContainer)
        
        cardNumberContainer.addSubview(first4)
        cardNumberContainer.addSubview(second4)
        cardNumberContainer.addSubview(third4)
        cardNumberContainer.addSubview(forth4)
        
        frontOfCardContents.addSubview(cardholderNameLabel)
        frontOfCardContents.addSubview(fullName)
        
        frontOfCardContents.addSubview(expirationLabel)
        frontOfCardContents.addSubview(expirationDate)
        super.configureView()
        
        layer.cornerRadius = 6
        
        brandBox.layer.cornerRadius = 4
        
        cardNumberLabel.label.textColor = UIColor(red: 149/255, green: 133/255, blue: 232/255, alpha: 1.0)
        cardNumberLabel.label.text = "CARD NUMBER"
        cardNumberLabel.label.font = Fonts.createSize(12)
        
        cardNumberContainer.layer.cornerRadius = 4
        cardNumberContainer.backgroundColor = .clear
        cardNumberContainer.layer.borderColor = Colors.registrationDark.cgColor
        cardNumberContainer.layer.borderWidth = 1
        
        cardholderNameLabel.label.textColor = UIColor(red: 149/255, green: 133/255, blue: 232/255, alpha: 1.0)
        cardholderNameLabel.label.text = "CARDHOLDER NAME"
        cardholderNameLabel.label.font = Fonts.createSize(12)
        
        expirationLabel.label.textColor = UIColor(red: 149/255, green: 133/255, blue: 232/255, alpha: 1.0)
        expirationLabel.label.text = "EXP"
        expirationLabel.label.font = Fonts.createSize(12)
        
        applyConstraints()
    }
    override func applyConstraints() {
        frontOfCardContents.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.87)
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        brandBox.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.24)
            make.height.equalTo(40)
        }
        cardNumberLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(25)
            make.centerY.equalToSuperview().multipliedBy(0.55)
        }
        cardNumberContainer.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(35)
            make.width.equalToSuperview()
            make.top.equalTo(cardNumberLabel.snp.bottom)
        }

        first4.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
			make.left.equalToSuperview().inset(7)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalToSuperview()
        }
        second4.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalToSuperview()
            make.left.equalTo(first4.snp.right)
        }
        third4.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalToSuperview()
            make.left.equalTo(second4.snp.right)
        }
        forth4.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalToSuperview()
            make.left.equalTo(third4.snp.right)
        }
        fullName.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(15)
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
        cardholderNameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.bottom.equalTo(fullName.snp.top)
        }
        expirationDate.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(15)
            make.right.equalToSuperview()
        }
        expirationLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(expirationDate.snp.top)
            make.right.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalToSuperview().multipliedBy(0.3)
        }
    }
}

fileprivate class AddNewCard : InteractableView, Interactable {
    
    var title = UILabel()
    
    override func configureView(){
        addSubview(title)
        super.configureView()
        
        isUserInteractionEnabled = true
        
        title.text = "Next »"
        title.textColor = UIColor.white.withAlphaComponent(0.3)
        title.font = Fonts.createBoldSize(20)
        title.textAlignment = .right
        title.adjustsFontSizeToFitWidth = true
        
        applyConstraints()
    }
    override func applyConstraints() {
        
        title.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
}

class LearnerPayment : BaseViewController {
    
    override var contentView: LearnerPaymentView {
        return view as! LearnerPaymentView
    }
    
    override func loadView() {
        view = LearnerPaymentView()
    }
    
    private var flipped : Bool = false
    private var cvcLength = 3
    private var segementGrouping  = [4,4,4,4]
    private var card = STPCardParams()
    private var brand : STPCardBrand? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTextFieldTargets()
        
        contentView.flipToFront.isHidden = true
        contentView.layoutIfNeeded()
        
        contentView.frontOfCard.first4.delegate = self
        contentView.frontOfCard.second4.delegate = self
        contentView.frontOfCard.third4.delegate = self
        contentView.frontOfCard.forth4.delegate = self
        contentView.frontOfCard.expirationDate.delegate = self
        contentView.frontOfCard.fullName.delegate = self
        contentView.backOfCard.CVC.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.nextButton.isUserInteractionEnabled = false
        contentView.frontOfCard.first4.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.frontOfCard.applyGradient(firstColor: UIColor(red: 66/255, green: 53/255, blue: 97/255, alpha: 1.0).cgColor, secondColor: (Colors.sidebarPurple.cgColor), angle: 60, frame: contentView.frontOfCard.bounds, cornerRadius: 6)
        
        contentView.backOfCard.applyGradient(firstColor: UIColor(red: 66/255, green: 53/255, blue: 97/255, alpha: 1.0).cgColor, secondColor: (Colors.sidebarPurple.cgColor), angle: 60, frame: contentView.backOfCard.bounds, cornerRadius: 6)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpTextFieldTargets() {
        contentView.backOfCard.CVC.addTarget(self, action: #selector(CVC(_:)), for: .editingChanged)
        contentView.frontOfCard.first4.addTarget(self, action: #selector(textFieldsValid(_:)), for: .editingChanged)
        contentView.frontOfCard.second4.addTarget(self, action: #selector(textFieldsValid(_:)), for: .editingChanged)
        contentView.frontOfCard.third4.addTarget(self, action: #selector(textFieldsValid(_:)), for: .editingChanged)
        contentView.frontOfCard.forth4.addTarget(self, action: #selector(textFieldsValid(_:)), for: .editingChanged)
        contentView.frontOfCard.expirationDate.addTarget(self, action: #selector(textFieldsValid(_:)), for: .editingChanged)
        contentView.frontOfCard.fullName.addTarget(self, action: #selector(textFieldsValid(_:)), for: .editingChanged)
        
    }
    private func getCardNumber() -> String {
        return (contentView.frontOfCard.first4.text! + contentView.frontOfCard.second4.text! + contentView.frontOfCard.third4.text! + contentView.frontOfCard.forth4.text!)
    }
    
    @objc func textFieldsValid(_ textField: UITextField){
        
        card.number = getCardNumber()
        
        var lengths = [Int]()
        
        let cardBrand = STPCardValidator.brand(forNumber: card.number!)
        cardBrandLayout(brand: cardBrand)
        contentView.frontOfCard.brandBox.image = STPImageLibrary.brandImage(for: cardBrand)
        
        for length in STPCardValidator.lengths(for: cardBrand) { lengths.append(Int(truncating: length)) }
        
        let min = lengths.min()
        let max = lengths.max()
        
        guard
            let cardNumber = card.number?.count, cardNumber >= min! && cardNumber <= max!,
            STPCardValidator.validationState(forNumber: card.number!, validatingCardBrand: true) == .valid
            else {
                contentView.isCardNumberValid(false)
                contentView.invalidInformation()
                return
        }
        contentView.isCardNumberValid(true)
        
        guard
            let fullName = contentView.frontOfCard.fullName.text, fullName.fullNameRegex()
            else {
                contentView.frontOfCard.fullName.textColor = .red
                contentView.invalidInformation()
                return
        }
        card.name = fullName
        contentView.frontOfCard.fullName.textColor = .white
        
        guard
            let expDate = contentView.frontOfCard.expirationDate.text, expDate.count == 5,
            STPCardValidator.validationState(forExpirationYear: String(expDate.suffix(2)), inMonth: String(expDate.prefix(2))) == .valid
            else {
                contentView.frontOfCard.expirationDate.textColor = .red
                contentView.invalidInformation()
                return
        }
        
        card.expYear = UInt(expDate.suffix(2))!
        card.expMonth = UInt(expDate.prefix(2))!
        contentView.frontOfCard.expirationDate.textColor = .white
        
        contentView.nextButton.isUserInteractionEnabled = true
        contentView.nextButton.alpha = 1.0
        contentView.nextButton.title.textColor = .white
        
    }
    
    @objc private func CVC(_ textField: UITextField) {
        if contentView.backOfCard.CVC.text!.count == cvcLength {
            contentView.nextButton.isUserInteractionEnabled = true
            contentView.nextButton.alpha = 1.0
            contentView.nextButton.title.textColor = .white
            card.cvc = contentView.backOfCard.CVC.text!
        } else {
            contentView.nextButton.isUserInteractionEnabled = false
            contentView.nextButton.alpha = 0.4
            contentView.nextButton.title.textColor.withAlphaComponent(0.4)
        }
    }
    
    private func cardBrandLayout(brand: STPCardBrand) {
        if self.brand != brand {
            contentView.brandDidSwitch()
        }
        
        if brand == .amex {
            contentView.layoutAmexCard()
            cvcLength = 4
            self.brand = brand
            segementGrouping = [4,6,5,0]
        } else if brand == .dinersClub {
            contentView.layoutDinersCard()
            cvcLength = 3
            self.brand = brand
            segementGrouping =  [4,4,4,2]
        } else {
            contentView.defaultLayout()
            cvcLength = 3
            self.brand = brand
            segementGrouping = [4,4,4,4]
        }
    }
    
    private func flipCard() {
        if !flipped {
            let options : UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews, .preferredFramesPerSecond60, .curveEaseInOut]
            
            UIView.transition(with: contentView.frontOfCard, duration: 0.5, options: options, animations: {
                self.contentView.frontOfCard.isHidden = true
            })
            UIView.transition(with: contentView.backOfCard, duration: 0.5, options: options, animations: {
                self.contentView.backOfCard.isHidden = false
                self.contentView.backOfCard.CVC.becomeFirstResponder()
            })
        } else {
            let options : UIViewAnimationOptions = [.transitionFlipFromLeft, .showHideTransitionViews, .preferredFramesPerSecond60, .curveEaseInOut]
            
            UIView.transition(with: contentView.backOfCard, duration: 0.5, options: options, animations: {
                self.contentView.backOfCard.isHidden = true
            })
            UIView.transition(with: contentView.frontOfCard, duration: 0.5, options: options, animations: {
                self.contentView.frontOfCard.isHidden = false
                self.contentView.subtitleLabel.label.text = "Enter Your Card Number"
            })
        }
        flipped = !flipped
    }
    
    private func nextButtonPressed() {
        if !flipped {
            flipCard()
            contentView.flipToFront.isHidden = false
            contentView.invalidInformation()
            contentView.nextButton.title.text = "Add Card »"
            contentView.subtitleLabel.label.text = "Enter Your CVV Number"
            
        } else {
            self.displayLoadingOverlay()
			Stripe.attachSource(cusID: CurrentUser.shared.learner.customer, adding: self.card, completion: { (error) in
                if let error = error {
                    print("Error: ", error.localizedDescription)
                    self.contentView.nextButton.isUserInteractionEnabled = true
                } else {
					let nav = self.navigationController
					let transition = CATransition()
					CurrentUser.shared.learner.hasPayment = true
					DispatchQueue.main.async {
						nav?.view.layer.add(transition.popFromTop(), forKey: nil)
						nav?.popBackToMain()
					}
                }
				self.dismissOverlay()
            })
        }
    }
    
    override func handleNavigation() {
        if (touchStartView == nil) {
            return
        } else if (touchStartView == contentView.nextButton){
            print("pressed")
            nextButtonPressed()
            contentView.nextButton.isUserInteractionEnabled = false
        } else if (touchStartView == contentView.flipToFront) {
            flipCard()
            contentView.flipToFront.isHidden = true
            contentView.nextButton.title.text = "Next »"
            contentView.backOfCard.CVC.text = ""
            contentView.subtitleLabel.label.text = "Enter Your Card Number"
            textFieldsValid(contentView.frontOfCard.fullName)
        }
    }
}

extension LearnerPayment : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")
        
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length

        if ((textField as? CreditCardNumberTextField) != nil) {
            
            switch textField {
            case contentView.frontOfCard.first4:
                if newLength <= segementGrouping[0] { return string == filtered }
                else {
                    textField.endEditing(true)
                    if contentView.frontOfCard.second4.text!.count == segementGrouping[1] { return false }
                    else { return string == filtered }
                }
                
            case contentView.frontOfCard.second4:
                if newLength <= segementGrouping[1] { return string == filtered }
                else {
                    textField.endEditing(true)
                    if contentView.frontOfCard.third4.text!.count == segementGrouping[2] { return false }
                    else { return string == filtered }
                }
            case contentView.frontOfCard.third4:
                if newLength <= segementGrouping[2] { return string == filtered }
                else {
                    textField.endEditing(true)
                    if contentView.frontOfCard.forth4.text!.count == segementGrouping[3] { return false }
                    else { return string == filtered }
                }
            case contentView.frontOfCard.forth4:
                if newLength <= segementGrouping[3] { return string == filtered }
                else {
                    textField.endEditing(true)
                    if contentView.frontOfCard.expirationDate.text!.count == 5 { return false }
                    else { return string == filtered }
                }
            default:
                break
            }
            return false
        }
        
        if textField == contentView.frontOfCard.expirationDate {
            if newLength <= 5 {
                if text.count == 2 {
                    if !(string == "") { textField.text! += "/" }
                }
                return string == filtered
            } else{
                textField.endEditing(true)
                return !(string == filtered)
            }
        }
        if textField == contentView.frontOfCard.fullName {
            if string == "" { return true }
            if newLength <= 20 { return !(string == filtered) }
            return true
        }
        if textField == contentView.backOfCard.CVC {
            if newLength <= cvcLength { return string == filtered }
            else {
                textField.endEditing(true)
                return false
            }
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
            
        case contentView.frontOfCard.first4:
            contentView.frontOfCard.second4.becomeFirstResponder()
            
        case contentView.frontOfCard.second4:
            contentView.frontOfCard.third4.becomeFirstResponder()
            
        case contentView.frontOfCard.third4:
            if segementGrouping[3] == 0 { contentView.frontOfCard.fullName.becomeFirstResponder() }
            else { contentView.frontOfCard.forth4.becomeFirstResponder() }
            
        case contentView.frontOfCard.forth4:
            contentView.frontOfCard.fullName.becomeFirstResponder()
            
        case contentView.frontOfCard.fullName:
            contentView.frontOfCard.fullName.resignFirstResponder()
            contentView.frontOfCard.expirationDate.becomeFirstResponder()
            
        default:
            break
        }
    }
}
