//
//  Stripe.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/29/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

import Stripe
import Alamofire

class Stripe {
	
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
	
	class func createConnectAccountToken(ssnLast4: String, line1: String, city: String, state: String, zipcode: String, _ completion: @escaping STPTokenCompletionBlock) {
		
		let name = CurrentUser.shared.learner.name.split(separator: " ")
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/mm/yyyy"
		let date = dateFormatter.date(from: CurrentUser.shared.learner.birthday!)
		
		let legalEntityParams = STPLegalEntityParams()
		
		legalEntityParams.businessName = "QuickTutor - Tutor - \(CurrentUser.shared.learner.name!)"
		legalEntityParams.entityTypeString = "individual"
		legalEntityParams.phoneNumber = CurrentUser.shared.learner.phone
		legalEntityParams.ssnLast4 = ssnLast4
		legalEntityParams.firstName = String(name[0])
		legalEntityParams.lastName = String(name[1])
		
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
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/connect.php"
		let params = ["acct_token" : connectAccountToken, "bank_token" : bankAccountToken]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success(var value):
					value = String(value.filter{ !" \n\t\r".contains($0)})
					completion(nil, value)
				case .failure(let error):
					completion(error, nil)
				}
			})
	}
	class func retrieveConnectAccount(acctId: String, _ completion: @escaping AWConnectedAccountErrorBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/retrieveconnect.php"
		let params : [String : Any] = ["acct" : acctId]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				
				switch response.result {
				case .success:
					guard let data = response.data else { return completion(NSError(domain: "Error Loading Data", code: 4, userInfo: ["description" : "Unable to update default bank account."]), nil) }
						do {
							let account : ConnectAccount = try JSONDecoder().decode(ConnectAccount.self, from: data)
							completion(nil, account)
						} catch {
							completion(NSError(domain: "Error", code: 1, userInfo: ["description" : "Unable to find connect account object."]), nil)
						}
				case .failure(let error):
					completion(error, nil)
				}
			})
	}
	
	class func destinationCharge(acctId: String, customerId: String, sourceId: String, amount: Int, fee: Int, description: String, _ completion: @escaping (Error?) -> ()) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/charge.php"
		let params : [String : Any] = ["acct" : acctId, "customer" : customerId, "source": sourceId, "fee" : fee, "amount" : amount, "description" : description]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success(let value):
					print(value)
					completion(nil)
				case .failure(let error):
					completion(error)
				}
			})
	}
	
	class func retrieveBankList(acctId: String, _ completion: @escaping AWExternalAccountErrorBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/retrievebank.php"
		let params : [String : Any] = ["acct" : acctId]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success:
					guard let data = response.data else { return }
					
					do {
						let externalAccounts : ExternalAccounts = try JSONDecoder().decode(ExternalAccounts.self, from: data)
						completion(nil, externalAccounts)
					} catch {
						completion(NSError(domain: "Error loading data", code: 3, userInfo: ["description" : "Unable to load external accounts."]), nil)
					}
				case .failure(let error):
					completion(error, nil)
				}
			})
	}
	
	class func retrieveBalanceTransactionList(acctId: String, _ completion: @escaping AWBalanceTransactionErrorBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/transfer.php"
		let params : [String : Any] = ["acct" : acctId]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success:
					guard let data = response.data else { return completion(NSError(domain: "Error Loading Data", code: 4, userInfo: ["description" : "Unable to update default bank account."]), nil) }
						do {
							let transaction : BalanceTransaction = try JSONDecoder().decode(BalanceTransaction.self, from: data)
							completion(nil,transaction)
						} catch {
							completion(NSError(domain: "Error Loading Data", code: 4, userInfo: ["description" : "Unable to update default bank account."]), nil)
						}
				case .failure(let error):
					completion(error,nil)
				}
			})
	}
	
	class func retrieveCustomer(cusID: String, _ completion: @escaping STPCustomerCompletionBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/retrievecustomer.php"
		let params : [String : Any] = ["customer" : cusID]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseJSON(completionHandler: { (response) in
				switch response.result {
					
				case .success:
					let deserializer : STPCustomerDeserializer = STPCustomerDeserializer(data: response.data!, urlResponse: response.response, error: response.error)
					if let error = deserializer.error {
						completion(nil, error)
					} else if let customer = deserializer.customer {
						completion(customer, nil)
					}
				case .failure(let error):
					completion(nil, error)
				}
			})
	}
	
	class func attachSource(cusID: String, adding card: STPCardParams, completion: @escaping (String?) -> Void) {
		STPAPIClient.shared().createToken(withCard: card) { (token, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			if let token = token {
				let requestString = "https://aqueous-taiga-32557.herokuapp.com/AttachSource.php"
				let params : [String : Any] = ["customer" : cusID, "token" :  token]
				Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
					.validate(statusCode: 200..<300)
					.responseString(completionHandler: { (response) in
						switch response.result {
						case .success(let value):
							if value == "success" {
								completion(nil)
							} else {
								completion(value)
							}
						case .failure(let error):
							completion(error.localizedDescription)
						}
					})
			}
		}
	}
	class func updateDefaultBank(account: String, bankId: String, completion: @escaping AWExternalAccountErrorBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/defaultbankaccount.php"
		let params : [String : Any] = ["acct" : account, "bankId" : bankId ]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success:
					guard let data = response.data else { return completion(NSError(domain: "Error Loading Data", code: 4, userInfo: ["description" : "Unable to update default bank account."]), nil) }
					do {
						let externalAccounts : ExternalAccounts = try JSONDecoder().decode(ExternalAccounts.self, from: data)
						return completion(nil, externalAccounts)
					} catch {
						return completion(NSError(domain: "Error Loading Data", code: 4, userInfo: ["description" : "Unable to update default bank account."]), nil)
					}
				case .failure(let error):
					return completion(error, nil)
				}
			})
	}
	
	class func removeBank(account: String, bankId: String, completion: @escaping AWExternalAccountErrorBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/removebank.php"
		let params : [String : Any] = ["acct" : account, "bankId" : bankId ]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success:
					guard let data = response.data else { return completion(NSError(domain: "Error Loading Data", code: 4, userInfo: ["description" : "Unable to update default bank account."]), nil) }
					do {
						let externalAccounts : ExternalAccounts = try JSONDecoder().decode(ExternalAccounts.self, from: data)
						completion(nil, externalAccounts)
					} catch {
						completion(NSError(domain: "Error Loading Data", code: 4, userInfo: ["description" : "Unable to update default bank account."]),nil)
					}
				case .failure(let error):
					completion(error,nil)
				}
			})
	}
	class func dettachSource(customer: STPCustomer, deleting card: STPCard, completion: @escaping STPCustomerCompletionBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/detachsource.php"
		let params : [String : Any] = ["customer" : customer.stripeID, "card" : card.stripeID ]
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseJSON(completionHandler: { (response) in
				switch response.result {
				case .success:
					if let data = response.data {
						let deserializer : STPCustomerDeserializer = STPCustomerDeserializer(data: data, urlResponse: response.response, error: response.error)
						if let error = deserializer.error {
							completion(nil, error)
						} else if let customer = deserializer.customer {
							completion(customer, nil)
						}
					} else {
						completion(nil, nil)
					}
				case .failure(let error):
					completion(nil, error)
				}
			})
	}
	
	class func updateDefaultSource(customer: STPCustomer, new defaultCard: STPCard, completion: @escaping STPCustomerCompletionBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/defaultsource.php"
		let params : [String : Any] = ["customer" : customer.stripeID, "card" : defaultCard.stripeID]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseJSON(completionHandler: { (response) in
				switch response.result {
				case .success:
					let deserializer : STPCustomerDeserializer = STPCustomerDeserializer(data: response.data!, urlResponse: response.response, error: response.error)
					if let error = deserializer.error {
						completion(nil, error)
					} else if let customer = deserializer.customer {
						completion(customer, nil)
					}
				case .failure(let error):
					completion(nil, error)
				}
			})
	}
	
	class func removeCustomer(customerId: String, completion: @escaping (Error?) -> Void) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/removecustomer.php"
		let params : [String : Any] = ["customer" : customerId]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success:
					completion(nil)
				case .failure(let error):
					completion(error)
				}
			})
	}
	class func removeConnectAccount(accountId: String, completion: @escaping (Error?) -> Void) {
		//check for balance.
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/removeconnect.php"
		let params : [String : Any] = ["acct" : accountId]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success(let value):
					completion(nil)
				case .failure(let error):
					completion(error)
				}
			})
	}
	
	deinit {
		print("StripeClass has De-initialized")
	}
}

