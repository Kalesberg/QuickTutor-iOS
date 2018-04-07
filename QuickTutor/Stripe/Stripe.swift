//
//  Stripe.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/29/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

import Stripe
import Alamofire

var Customer : STPCustomer! {
	
	willSet(newCustomer) {
		//additional setup when Customer is about to be updated.
	}
	didSet {
		//additional setup when Customer has been updated.
		UserDefaultData.localDataManager.updateValue(for: "numberOfCards", value: Customer.sources.count)
		NotificationCenter.default.post(name: .CustomerUpdated, object: nil)
		
	}
}
extension NSNotification.Name {
	static let CustomerUpdated = NSNotification.Name(Bundle.main.bundleIdentifier! + ".CustomerUpdated")
}

class Stripe {
	
	/*
	create connect account
	handle transfering funds
	*/
	static let stripeManager = Stripe()
	
	private init() {
		print("Stripe initialized.")
	}
	
	func initConnectAccount(completion: @escaping (Error?) -> Void) {
		//makes a call to heroku<->stripe to return the new connected account Id.
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/connect.php"
		
		let data = LearnerData.userData
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
			"bank_holder_name" : TutorRegistration.bankholderName,
			"routing_number" : TutorRegistration.routingNumber!,
			"account_number" : TutorRegistration.accountNumber!,
			
			]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success(var value):
					value = String(value.filter{ !" \n\t\r".contains($0)})
					TutorRegistration.stripeToken = value
					completion(nil)
				case .failure(let error):
					completion(error)
				}
			})
	}
	
	func createCustomer(_ completion: @escaping STPErrorBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/createcustomer.php"
		let params : [String : Any] = ["email" : Registration.email, "description" : "Student Account"]
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success(var value):
					value = String(value.filter{ !" \n\t\r".contains($0)})
					let newNode = ["cus" : value]
					FirebaseData.manager.updateValue(node: "student-info", value: newNode)
					completion(nil)
				case .failure(let error):
					completion(error)
				}
			})
	}
	
	func retrieveCustomer(_ completion: @escaping STPErrorBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/retrievecustomer.php"
		let params : [String : Any] = ["customer" : LearnerData.userData.customer]
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseJSON(completionHandler: { (response) in
				switch response.result {
				case .success:
					self.deserializeCustomer(response: response)
					completion(nil)
				case .failure(let error):
					completion(error)
				}
			})
	}
	
	private func deserializeCustomer(response: DataResponse<Any>) {
		let deserializer : STPCustomerDeserializer = STPCustomerDeserializer(data: response.data!, urlResponse: response.response, error: response.error)
		if let error = deserializer.error {
			print(error.localizedDescription)
		} else if let customer = deserializer.customer {
			Customer = customer
		}
	}
	
	func attachSource(adding card: STPCardParams, completion: @escaping STPErrorBlock) {
		STPAPIClient.shared().createToken(withCard: card) { (token, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			if let token = token {
				let requestString = "https://aqueous-taiga-32557.herokuapp.com/AttachSource.php"
				let params : [String : Any] = ["customer" : LearnerData.userData.customer!, "token" :  token]
				Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
					.validate(statusCode: 200..<300)
					.responseJSON(completionHandler: { (response) in
						switch response.result {
						case .success:
							self.deserializeCustomer(response: response)
							completion(nil)
						case .failure(let error):
							completion(error)
						}
					})
			}
		}
	}
	
	func dettachSource(customer: STPCustomer, deleting card: STPCard, completion: @escaping STPErrorBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/detachsource.php"
		let params : [String : Any] = ["customer" : customer.stripeID, "card" : card.stripeID ]
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseJSON(completionHandler: { (response) in
				switch response.result {
				case .success:
					self.deserializeCustomer(response: response)
					completion(nil)
				case .failure(let error):
					completion(error)
				}
			})
	}
	
	func updateDefaultSource(customer: STPCustomer, new defaultCard: STPCard, completion: @escaping STPErrorBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/defaultsource.php"
		let params : [String : Any] = ["customer" : customer.stripeID, "card" : defaultCard.stripeID]
		print(defaultCard.stripeID)
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseJSON(completionHandler: { (response) in
				switch response.result {
				case .success:
					self.deserializeCustomer(response: response)
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

