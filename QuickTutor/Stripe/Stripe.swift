//
//  Stripe.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/29/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

import Stripe
import Alamofire

class Stripe {
	
	/*
	create connect account
	handle transfering funds
	*/
	static let stripeManager = Stripe()
	
	private init() {
		print("Stripe initialized.")
	}
	
	class func createConnect(completion: @escaping (String?) -> Void) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/connect.php"
		
		guard let data = CurrentUser.shared.learner else { return }
		
		let dob = data.birthday.split(separator: "/")
		let name = data.name!.split(separator: " ")
		
		let params : [String : Any] = [
			"country" : "US",
			"type": "custom",
			"city": TutorRegistration.city!,
			"line1": TutorRegistration.line1!,
			"zipcode": TutorRegistration.zipcode!,
			"state": TutorRegistration.state!,
			"dob_day" : dob[0],
			"dob_month" : dob[1],
			"dob_year" : dob[2],
			"first_name" : name[0],
			"last_name" : name[1],
			"ssn_last_4" : TutorRegistration.last4SSN!,
			"currency" : "usd",
			"entity_type" : "individual",
			"bank_holder_name" : TutorRegistration.bankHoldersName!,
			"routing_number" : TutorRegistration.routingNumber!,
			"account_number" : TutorRegistration.accountNumber!,
			]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success(var value):
					value = String(value.filter{ !" \n\t\r".contains($0)})
					completion(value)
				case .failure:
					completion(nil)
				}
			})
	}
	
	class func retrieveConnectAccount(acctId: String, _ completion: @escaping (String?) -> Void) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/retrieveconnect.php"
		let params : [String : Any] = ["acct" : acctId]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success(let value):
					print(value)
					completion("value")
				case .failure(let error):
					print("Error: ", error)
					completion(error.localizedDescription)
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
	
	class func retrieveBankList(acctId: String, _ completion: @escaping (ConnectAccount?) -> Void) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/retrievebank.php"
		let params : [String : Any] = ["acct" : acctId]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success:
					print(response.value!)
					guard let data = response.data else { return }
					
					do {
						let account : ConnectAccount = try JSONDecoder().decode(ConnectAccount.self, from: data)
						completion(account)
					} catch {
						completion(nil)
					}
				case .failure:
					completion(nil)
				}
			})
	}
	
	class func retrieveBalanceTransactionList(acctId: String, _ completion: @escaping (BalanceTransaction?) -> Void) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/transfer.php"
		let params : [String : Any] = ["acct" : "acct_1COwHwARbMbNlmG8"]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success:
					if let data = response.data {
						do {
							let transaction : BalanceTransaction = try JSONDecoder().decode(BalanceTransaction.self, from: data)
							completion(transaction)
						} catch {
							completion(nil)
						}
					} else {
						completion(nil)
					}
				case .failure(let error):
					print("Error: ", error.localizedDescription)
					completion(nil)
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
	
	class func attachSource(cusID: String, adding card: STPCardParams, completion: @escaping STPErrorBlock) {
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
					.responseJSON(completionHandler: { (response) in
						switch response.result {
						case .success:
							completion(nil)
						case .failure(let error):
							completion(error)
						}
					})
			}
		}
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
	
	class  func updateDefaultSource(customer: STPCustomer, new defaultCard: STPCard, completion: @escaping STPCustomerCompletionBlock) {
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
	
	deinit {
		print("StripeClass has De-initialized")
	}
}

