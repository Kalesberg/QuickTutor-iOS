//
//  TutorAddBank.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/29/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit
import Stripe
import Alamofire

class TutorAddBankView : MainLayoutTitleBackTwoButton, Keyboardable {
    
    var nextButton = NavbarButtonNext()
    
    override var rightButton: NavbarButton {
        get {
            return nextButton
        }
        set {
            nextButton = newValue as! NavbarButtonNext
        }
    }
	
	var keyboardComponent = ViewComponent()
	var contentView = UIView()
	var nameTitle = SectionTitle()
	var nameTextfield = PaymentTextField()
	var routingNumberTitle = SectionTitle()
	var routingNumberTextfield = PaymentTextField()
	var accountNumberTitle = SectionTitle()
	var accountNumberTextfield  = PaymentTextField()
	
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
		
		title.label.text = "Payment"
		
		nameTitle.label.text = "Name"
		routingNumberTitle.label.text = "Routing Number"
		accountNumberTitle.label.text = "Account Number"
		
		nameTextfield.attributedPlaceholder = NSAttributedString(string: "Enter bank holder's name", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		nameTextfield.keyboardType = .asciiCapable
		
		routingNumberTextfield.attributedPlaceholder = NSAttributedString(string: "Enter Routing Number", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		routingNumberTextfield.keyboardType = .decimalPad
		
		accountNumberTextfield.attributedPlaceholder = NSAttributedString(string: "Enter Account Number", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		accountNumberTextfield.keyboardType = .decimalPad
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		contentView.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.85)
			make.top.equalTo(navbar.snp.bottom)
			make.centerX.equalToSuperview()
			make.bottom.equalTo(keyboardView.snp.top)
		}
		
		nameTitle.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.18)
			make.centerX.equalToSuperview()
		}
		
		nameTextfield.snp.makeConstraints { (make) in
			make.top.equalTo(nameTitle.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		
		routingNumberTitle.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.top.equalTo(nameTextfield.snp.bottom)
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.18)
		}
		
		routingNumberTextfield.snp.makeConstraints { (make) in
			make.top.equalTo(routingNumberTitle.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
		
		accountNumberTitle.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.top.equalTo(routingNumberTextfield.snp.bottom)
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.18)
		}
		
		accountNumberTextfield.snp.makeConstraints { (make) in
			make.top.equalTo(accountNumberTitle.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(30)
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		navbar.backgroundColor = Colors.tutorBlue
		statusbarView.backgroundColor = Colors.tutorBlue
	}
}

class TutorAddBank: BaseViewController {
	
	override var contentView: TutorAddBankView {
		return view as! TutorAddBankView
	}
	override func loadView() {
		view = TutorAddBankView()
	}
	
	var fullName : String!
	var routingNumber : String!
	var accountNumber : String!
	var validAccountData : Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let textFields = [contentView.nameTextfield, contentView.routingNumberTextfield, contentView.accountNumberTextfield]
		
		for textField in textFields{
			textField.delegate = self
			textField.returnKeyType = .next
			textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
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
	
	@objc private func textFieldDidChange(_ textField: UITextField) {
		
        guard let name = contentView.nameTextfield.text, name.fullNameRegex() else {
			contentView.nameTextfield.layer.borderColor = Colors.qtRed.cgColor
			validAccountData = false
            return
        }
		contentView.nameTextfield.layer.borderColor = Colors.green.cgColor

        print("Good Name")
        guard let routingNumber = contentView.routingNumberTextfield.text, routingNumber.count == 9 else {
			if contentView.routingNumberTextfield.text!.count > 1 {
				contentView.routingNumberTextfield.layer.borderColor = Colors.qtRed.cgColor
			}
			validAccountData = false
            return
        }
		contentView.routingNumberTextfield.layer.borderColor = Colors.green.cgColor

        print("Good routing")
        guard let accountNumber = contentView.accountNumberTextfield.text, accountNumber.count > 5 else {
			if contentView.accountNumberTextfield.text!.count > 1 {
				contentView.accountNumberTextfield.layer.borderColor = Colors.qtRed.cgColor
			}
			validAccountData = false
            return
        }
		contentView.accountNumberTextfield.layer.borderColor = Colors.green.cgColor

        print("Good account.")
		validAccountData = true
		
		self.fullName = name
		self.routingNumber = routingNumber
		self.accountNumber = accountNumber
	}

	private func addTutorBankAccount(fullname: String, routingNumber: String, accountNumber: String,_ completion: @escaping (Error?) -> Void) {
		
		let bankAccount = STPBankAccountParams()
		
		bankAccount.accountHolderName = fullname
		bankAccount.routingNumber = routingNumber
		bankAccount.accountNumber = accountNumber
		bankAccount.country = "US"
		
		STPAPIClient.shared().createToken(withBankAccount: bankAccount) { (token, error) in
			if let error = error {
				print(error.localizedDescription)
			} else if let token = token {
				let requestString = "https://aqueous-taiga-32557.herokuapp.com/addbank.php"
				let params : [String : Any] = ["acct" : CurrentUser.shared.tutor.acctId!, "token" : token]
				
				Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
					.validate(statusCode: 200..<300)
					.responseString(completionHandler: { (response) in
						switch response.result {
						case .success:
							CurrentUser.shared.tutor.hasPayoutMethod = true
							completion(nil)
						case .failure(let error):
							completion(error)
						}
				})
			}
		}
	}
	
	override func handleNavigation() {
		if (touchStartView is NavbarButtonNext) {
            contentView.rightButton.isUserInteractionEnabled = false
            
            if validAccountData {
				self.displayLoadingOverlay()
				addTutorBankAccount(fullname: self.fullName, routingNumber: self.routingNumber, accountNumber: self.accountNumber) { (error) in
					if let error = error {
						AlertController.genericErrorActionSheet(self, title: "Unable to Add Payout Method", message: error.localizedDescription)
						self.contentView.rightButton.isUserInteractionEnabled = true
					} else {
						self.navigationController?.popBackToTutorMain()
					}
					self.dismissOverlay()
				}
            } else {
                contentView.rightButton.isUserInteractionEnabled = true
            }
		}
	}
}
extension TutorAddBank : UITextFieldDelegate {
	
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
		
		let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
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

