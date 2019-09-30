//
//  TutorAddBank.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/29/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Alamofire
import SnapKit
import Stripe
import UIKit
import IQKeyboardManager

class TutorAddBank: BaseRegistrationController {
    
    var fullName: String!
    var routingNumber: String!
    var accountNumber: String!
    var validAccountData: Bool = false
    var isRegistration = false
    
    let contentView: TutorAddBankView = {
        let view = TutorAddBankView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        setupTextFields()
        progressView.setProgress(4/6)
        progressView.isHidden = !isRegistration
        if isRegistration {
            DispatchQueue.main.asyncAfter(deadline: .now() + BankInfoModal.INITIAL_DELAY) {
                self.showInfoModal()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared().isEnabled = false
        contentView.resignFirstResponder()
    }
    
    func setupTargets() {
        accessoryView.nextButton.addTarget(self, action: #selector(handleNext(_:)), for: .touchUpInside)
        accessoryView.nextButton.setTitle("NEXT", for: .normal)
        contentView.infoButton.addTarget(self, action: #selector(handleInfoButton(_:)), for: .touchUpInside)
        contentView.routingNumberInfoButton.addTarget(self, action: #selector(handleRoutingAndAccountButton(_:)), for: .touchUpInside)
        contentView.accountNumberInfoButton.addTarget(self, action: #selector(handleRoutingAndAccountButton(_:)), for: .touchUpInside)
    }
    
    func setupTextFields() {
        let textFields = [contentView.nameTextField.textField, contentView.routingNumberTextField.textField, contentView.accountNumberTextField.textField]
        accessoryView.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
        for textField in textFields {
            textField.delegate = self
            textField.returnKeyType = .next
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            textField.inputAccessoryView = accessoryView
        }
    }

    @objc private func textFieldDidChange(_: UITextField) {
        guard validateName() else { return }
        guard validateRoutingNumber() else { return }
        guard validateAccountNumber() else { return }
        validAccountData = true
    }
    
    func validateName() -> Bool {
        guard let name = contentView.nameTextField.textField.text, name.count <= 30, name.count >= 2 else {
            contentView.nameTextField.line.backgroundColor = Colors.qtRed
            validAccountData = false
            return false
        }
        contentView.nameTextField.line.backgroundColor = Colors.green
        fullName = name
        return true
    }
    
    func validateRoutingNumber() -> Bool {
        guard let routingNumber = contentView.routingNumberTextField.textField.text, routingNumber.count == 9 else {
            if contentView.routingNumberTextField.textField.text!.count > 1 {
                contentView.routingNumberTextField.line.backgroundColor = Colors.qtRed
            }
            validAccountData = false
            return false
        }
        contentView.routingNumberTextField.line.backgroundColor = Colors.green
        self.routingNumber = routingNumber
        return true
    }
    
    func validateAccountNumber() -> Bool {
        guard let accountNumber = contentView.accountNumberTextField.textField.text, accountNumber.count > 5 else {
            if contentView.accountNumberTextField.textField.text!.count > 1 {
                contentView.accountNumberTextField.line.backgroundColor = Colors.qtRed
            }
            validAccountData = false
            return false
        }
        contentView.accountNumberTextField.line.backgroundColor = Colors.green
        self.accountNumber = accountNumber
        return true
    }

    private func addTutorBankAccount(fullname: String, routingNumber: String, accountNumber: String, _ completion: @escaping (Error?) -> Void) {
        let bankAccount = STPBankAccountParams()

        bankAccount.accountHolderName = fullname
        bankAccount.routingNumber = routingNumber
        bankAccount.accountNumber = accountNumber
        bankAccount.country = "US"

        STPAPIClient.shared().createToken(withBankAccount: bankAccount) { token, error in
            guard let accId = CurrentUser.shared.tutor.acctId,
                let token = token else { return completion(error) }
            let requestString = "\(Constants.API_BASE_URL)/stripes/accounts/\(accId)/banks"
            let params = ["token": token]
            
            Alamofire.request(requestString, method: .post, parameters: params)
                .validate()
                .responseJSON() { response in
                    switch response.result {
                    case .success:
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
            }
        }
    }
    
    @objc func handleNext(_ sender: UIButton) {
        if contentView.nameTextField.textField.isFirstResponder {
            contentView.routingNumberTextField.textField.becomeFirstResponder()
        } else if contentView.routingNumberTextField.textField.isFirstResponder {
            contentView.accountNumberTextField.textField.becomeFirstResponder()
            accessoryView.nextButton.setTitle("CONTINUE", for: .normal)
        } else {
            guard validAccountData else { return }
            isRegistration ? createStripeAccount() : addBank()
        }
    }
    
    @objc func handleInfoButton(_ sender: UIButton) {
        showInfoModal()
    }
    
    @objc func handleRoutingAndAccountButton(_ sender: UIButton) {
        let _ = RoutingAndAccountModal.view
    }
    
    func showInfoModal() {
        let _ = BankInfoModal.view
    }

    func addBank() {
        displayLoadingOverlay()
        addTutorBankAccount(fullname: fullName, routingNumber: routingNumber, accountNumber: accountNumber) { error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Unable to Add Payout Method", message: error.localizedDescription)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            self.dismissOverlay()
        }
    }
    
    func createStripeAccount() {
        StripeService.createBankAccountToken(accountHoldersName: fullName, routingNumber: routingNumber, accountNumber: accountNumber) { token, _ in
            if let token = token {
                TutorRegistration.bankToken = token
                self.navigationController?.pushViewController(TutorSSNViewController(), animated: true)
            } else {
                AlertController.genericErrorAlert(self, title: "Bank Account Error", message: "Unable to create bank account. Please verify the information is correct.")
            }
            self.dismissOverlay()
        }
    }
}

extension TutorAddBank: UITextFieldDelegate {
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case contentView.nameTextField.textField:
            contentView.routingNumberTextField.textField.becomeFirstResponder()
        case contentView.routingNumberTextField.textField:
            contentView.accountNumberTextField.textField.becomeFirstResponder()
        case contentView.accountNumberTextField.textField:
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
        case contentView.nameTextField.textField:
            if string == "" { return true }
            if newLength <= 20 { return !(string == filtered) }
            return true
        case contentView.routingNumberTextField.textField:
            return (filtered == string)
        case contentView.accountNumberTextField.textField:
            return (filtered == string)
        default:
            return false
        }
    }
}
