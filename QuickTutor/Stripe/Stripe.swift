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
	
	func connect() {
		//makes a call to heroku<->stripe to return the new connected account Id.
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/connect.php"
		
		let params : [String : Any] = [
			"country" : TutorRegistration.country,
			"type": "custom",
			"address_city" : TutorRegistration.city ,
			"address_line1" : TutorRegistration.address_line1,
			"address_postal_code" : TutorRegistration.zipcode,
			"address_state" : TutorRegistration.state,
			"dob_day" : Registration.dob,
			"first_name" : Registration.firstName,
			"last_name" : Registration.lastName,
			"ssn_last_4" : TutorRegistration.last4SSN,
			"currency" : "usd",
			"entity_type" : "individual" ,
			"routing_number" : TutorRegistration.routingNumber,
			"account_number" : TutorRegistration.accountNumber,
			]
		
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.responseString(completionHandler: { (response) in
				print(response.value!)
				var responseString = (response.value!).components(separatedBy: "/")
				let result = responseString[0]
				let value = responseString[1]
				if result == "success" {
					let newNode = ["stripeAccount": value]
					if (Tutor.sharedManager.updateValue(value: newNode)) {
						return
					}else{
						//show firebase error message
					}
				}else {
					//show error message.
					print(value)
				}
			})
	}
	
	func createCustomer(_ completion: @escaping STPErrorBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/createcustomer.php"
		let params : [String : Any] = ["email" : "UserDefaultData.localDataManager.email", "description" : "Student Account"]
		Alamofire.request(requestString, method: .post, parameters: params, encoding: URLEncoding.default)
			.validate(statusCode: 200..<300)
			.responseString(completionHandler: { (response) in
				switch response.result {
				case .success(var value):
					value = String(value.filter{ !" \n\t\r".contains($0)})
					let newNode = ["customer" : value]
					FirebaseData.manager.updateValue(value: newNode)
					Registration.customerId = value
					completion(nil)
				case .failure(let error):
					completion(error)
				}
			})
	}
	
	func retrieveCustomer(_ completion: @escaping STPErrorBlock) {
		let requestString = "https://aqueous-taiga-32557.herokuapp.com/retrievecustomer.php"
		let params : [String : Any] = ["customer" : UserData.userData.customer]
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
				let params : [String : Any] = ["customer" : UserData.userData.customer!, "token" :  token]
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
