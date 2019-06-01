//
//  Stripe.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/29/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

import Stripe
import Alamofire

class StripeService {
	
	private init() {
		print("Stripe initialized.")
	}
	
	typealias AWConnectedAccountErrorBlock = (Error?, ConnectAccount?) -> Void
	typealias AWErrorValueCompletionblock = (Error?, String?) -> Void
	typealias AWExternalAccountErrorBlock = (Error?, ExternalAccounts?) -> Void
	typealias AWBalanceTransactionErrorBlock = (Error?, BalanceTransaction?) -> Void
	
	class func createBankAccountToken(accountHoldersName: String, routingNumber: String, accountNumber: String, completion: @escaping STPTokenCompletionBlock) {
		
		let bankAccountParams = STPBankAccountParams()
		
		bankAccountParams.country = "US"
		bankAccountParams.currency = "usd"
		bankAccountParams.accountHolderType = .individual
		bankAccountParams.accountHolderName = accountHoldersName
		bankAccountParams.routingNumber = routingNumber
		bankAccountParams.accountNumber = accountNumber
		
		STPAPIClient.shared().createToken(withBankAccount: bankAccountParams) { (token, error) in
			if let error = error {
				completion(nil, error)
			} else if let token = token {
				completion(token, nil)
			}
		}
	}
	
	class func createConnectAccountToken(ssn: String, line1: String, city: String, state: String, zipcode: String, _ completion: @escaping STPTokenCompletionBlock) {
		
		let name = CurrentUser.shared.learner.name.split(separator: " ")
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM/yyyy"
		let date = dateFormatter.date(from: CurrentUser.shared.learner.birthday!)
		
		let legalEntityParams = STPLegalEntityParams()
		legalEntityParams.businessName = "QuickTutor - Tutor - \(CurrentUser.shared.learner.name!)"
		legalEntityParams.entityTypeString = "individual"
        if let phoneNumber = CurrentUser.shared.learner.phone, !phoneNumber.isEmpty {
            legalEntityParams.phoneNumber = phoneNumber
        }
		legalEntityParams.ssnLast4 = String(ssn.suffix(4))
		legalEntityParams.firstName = String(name[0])
		legalEntityParams.lastName = String(name[1])
		legalEntityParams.personalIdNumber = ssn
		
		if let date = date {
			legalEntityParams.dateOfBirth = Calendar.current.dateComponents([.month, .day, .year], from: date)
		}
		
		let address = STPAddress()
		address.line1 = TutorRegistration.line1
		address.city = TutorRegistration.city
		address.state = TutorRegistration.state
		address.postalCode = TutorRegistration.zipcode
		
		legalEntityParams.address = address
		
		let connectAccountParams = STPConnectAccountParams(tosShownAndAccepted: true, legalEntity: legalEntityParams)

		STPAPIClient.shared().createToken(withConnectAccount: connectAccountParams) { (token, error) in
			if let error = error {
				completion(nil, error)
			} else if let token = token {
				completion(token, nil)
			} else {
				completion(nil,nil)
			}
		}
	}
	
	class func createConnectAccount(bankAccountToken: STPToken, connectAccountToken: STPToken, _ completion: @escaping AWErrorValueCompletionblock) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/accounts"
        let params = ["acct_token": connectAccountToken, "bank_token": bankAccountToken]
        Alamofire.request(requestString, method: .post, parameters: params)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success(let value as [String: Any]):
                    if let accId = value["id"] as? String {
                        completion(nil, accId)
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(error, nil)
                default:
                    completion(nil, nil)
                }
        }
	}
	class func retrieveConnectAccount(acctId: String, _ completion: @escaping AWConnectedAccountErrorBlock) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/accounts/\(acctId)"
        Alamofire.request(requestString, method: .get)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = response.data,
                        let objAccount = try? JSONDecoder().decode(ConnectAccount.self, from: data) {
                        completion(nil, objAccount)
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(error, nil)
                }
        }
	}
	
    class func destinationCharge(acctId: String, customerId: String, customerStripeId: String, sourceId: String, amount: Int, fee: Int, description: String, completion: @escaping (Error?) -> ()) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/charges"
        let params: [String: Any] = [
            "acct": acctId,
            "customer": customerStripeId,
            "source": sourceId,
            "fee": fee,
            "amount": amount,
            "description": description,
            "customerId": customerId]
        
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
    
    class func makeApplePay(acctId: String, customerId: String, receiptEmail: String, tokenId: String, amount: Int, fee: Int, description: String, completion: @escaping (Error?) -> ()) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/applepay"
        let params: [String: Any] = [
            "acct": acctId,
            "receiptEmail": receiptEmail,
            "source": tokenId,
            "fee": fee,
            "amount": amount,
            "description": description,
            "customerId": customerId]
        
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
    
	class func retrieveBankList(acctId: String, _ completion: @escaping AWExternalAccountErrorBlock) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/accounts/\(acctId)/banks"
        
        Alamofire.request(requestString, method: .get)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = response.data,
                        let objExternalAccounts = try? JSONDecoder().decode(ExternalAccounts.self, from: data) {
                        completion(nil, objExternalAccounts)
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(error, nil)
                }
        }
	}
	
	class func retrieveBalanceTransactionList(acctId: String, _ completion: @escaping AWBalanceTransactionErrorBlock) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/accounts/\(acctId)/transactions"
        
        Alamofire.request(requestString, method: .get)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = response.data,
                        let objBalanceTransaction = try? JSONDecoder().decode(BalanceTransaction.self, from: data) {
                        completion(nil, objBalanceTransaction)
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(error, nil)
                }
        }
	}
	
	class func retrieveCustomer(cusID: String, _ completion: @escaping STPCustomerCompletionBlock) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/customers/\(cusID)"
        
        Alamofire.request(requestString, method: .get)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = response.data {
                        let deserializer = STPCustomerDeserializer(data: data, urlResponse: response.response, error: response.error)
                        if let error = deserializer.error {
                            completion(nil, error)
                        } else if let objCustomer = deserializer.customer {
                            completion(objCustomer, nil)
                        } else {
                            completion(nil, nil)
                        }
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(nil, error)
            }
        }
	}
	
	class func attachSource(cusID: String, adding card: STPCardParams, completion: @escaping (String?) -> Void) {
		STPAPIClient.shared().createToken(withCard: card) { (token, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			if let token = token {
                let requestString = "\(Constants.API_BASE_URL)/stripes/customers/\(cusID)/sources"
                let params = ["token": token]
                
                Alamofire.request(requestString, method: .post, parameters: params)
                    .validate()
                    .responseJSON() { response in
                        switch response.result {
                        case .success:
                            completion(nil)
                        case .failure(let error):
                            completion(error.localizedDescription)
                        }
                }
			}
		}
	}
    
    
    class func attachSource(cusID: String, with token: STPToken, completion: @escaping (String?) -> Void) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/customers/\(cusID)/sources"
        let params = ["token": token]
        
        Alamofire.request(requestString, method: .post, parameters: params)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error.localizedDescription)
                }
        }
    }

    
	class func updateDefaultBank(account: String, bankId: String, completion: @escaping AWExternalAccountErrorBlock) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/accounts/\(account)/banks/default"
        let params = ["bankId": bankId]
        
        Alamofire.request(requestString, method: .put, parameters: params)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = response.data,
                        let objExternalAccounts = try? JSONDecoder().decode(ExternalAccounts.self, from: data) {
                        completion(nil, objExternalAccounts)
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(error, nil)
                }
        }
	}
	
	class func removeBank(account: String, bankId: String, completion: @escaping AWExternalAccountErrorBlock) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/accounts/\(account)/banks"
        let params = ["bankId": bankId]
        
        Alamofire.request(requestString, method: .delete, parameters: params)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = response.data,
                        let objExternalAccounts = try? JSONDecoder().decode(ExternalAccounts.self, from: data) {
                        completion(nil, objExternalAccounts)
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(error, nil)
                }
        }
	}
	class func detachSource(customer: STPCustomer, deleting card: STPCard, completion: @escaping STPCustomerCompletionBlock) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/customers/\(customer.stripeID)/sources"
        let params = ["card": card.stripeID]
        
        Alamofire.request(requestString, method: .delete, parameters: params)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = response.data {
                        let deserializer : STPCustomerDeserializer = STPCustomerDeserializer(data: data, urlResponse: response.response, error: response.error)
                        if let error = deserializer.error {
                            completion(nil, error)
                        } else if let objCustomer = deserializer.customer {
                            completion(objCustomer, nil)
                        } else {
                            completion(nil, nil)
                        }
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(nil, error)
                }
        }
	}
	
	class func updateDefaultSource(customer: STPCustomer, new defaultCard: STPCard, completion: @escaping STPCustomerCompletionBlock) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/customers/\(customer.stripeID)/sources/default"
        let params = ["cardId": defaultCard.stripeID]
        
        Alamofire.request(requestString, method: .put, parameters: params)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = response.data {
                        let deserializer : STPCustomerDeserializer = STPCustomerDeserializer(data: data, urlResponse: response.response, error: response.error)
                        if let error = deserializer.error {
                            completion(nil, error)
                        } else if let objCustomer = deserializer.customer {
                            completion(objCustomer, nil)
                        } else {
                            completion(nil, nil)
                        }
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(nil, error)
                }
        }
        
	}
	
	class func removeCustomer(customerId: String, completion: @escaping (Error?) -> Void) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/customers/\(customerId)"
        
        Alamofire.request(requestString, method: .get)
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
	class func removeConnectAccount(accountId: String, completion: @escaping (Error?) -> Void) {
        let requestString = "\(Constants.API_BASE_URL)/stripe/accounts/\(accountId)"
        
        Alamofire.request(requestString, method: .delete)
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
	
	deinit {
		print("StripeClass has De-initialized")
	}
}

