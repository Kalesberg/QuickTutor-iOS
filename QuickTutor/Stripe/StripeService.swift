//
//  Stripe.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/29/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

import Stripe
import Alamofire
import ObjectMapper

class QTStripeError: Mappable {
    var error: Error!
    var type: String?
    var code: String?
    var message: String?
    var param: String?
    
    init(error: Error?) {
        self.error = error
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        type            <- map["type"]
        code            <- map["code"]
        message         <- map["message"]
        param           <- map["param"]
    }
}

class StripeService {
	 
	typealias AWConnectedAccountErrorBlock = (QTStripeError?, ConnectAccount?) -> Void
	typealias AWErrorValueCompletionblock = (QTStripeError?, String?) -> Void
	typealias AWExternalAccountErrorBlock = (QTStripeError?, ExternalAccounts?) -> Void
	typealias AWBalanceTransactionErrorBlock = (QTStripeError?, BalanceTransaction?) -> Void
	
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
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(objStripeError, nil)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(objStripeError, nil)
                    }
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
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(objStripeError, nil)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(objStripeError, nil)
                    }
                }
        }
	}
	
    class func destinationCharge(acctId: String, customerId: String, customerStripeId: String, sourceId: String, amount: Int, fee: Int, description: String, completion: @escaping (QTStripeError?) -> ()) {
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
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(objStripeError)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(objStripeError)
                    }
                }
        }
	}
    
    class func makeApplePay(acctId: String, customerId: String, receiptEmail: String, tokenId: String, amount: Int, fee: Int, description: String, completion: @escaping (QTStripeError?) -> ()) {
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
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(objStripeError)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(objStripeError)
                    }
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
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(objStripeError, nil)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(objStripeError, nil)
                    }
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
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(objStripeError, nil)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(objStripeError, nil)
                    }
                }
        }
	}
	
	class func retrieveCustomer(cusID: String, _ completion: @escaping ((STPCustomer?, QTStripeError?) -> Void)) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/customers/\(cusID)"
        
        Alamofire.request(requestString, method: .get)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = response.data {
                        let deserializer = STPCustomerDeserializer(data: data, urlResponse: response.response, error: response.error)
                        if let error = deserializer.error {
                            let objStripeError = QTStripeError(error: error)
                            completion(nil, objStripeError)
                        } else if let objCustomer = deserializer.customer {
                            completion(objCustomer, nil)
                        } else {
                            completion(nil, nil)
                        }
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(nil, objStripeError)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(nil, objStripeError)
                    }
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
                            if let data = response.data,
                                let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                                let dicError = dicData,
                                let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                                completion(objStripeError.message)
                            } else {
                                completion(error.localizedDescription)
                            }
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
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        completion(objStripeError.message)
                    } else {
                        completion(error.localizedDescription)
                    }
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
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(objStripeError, nil)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(objStripeError, nil)
                    }
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
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(objStripeError, nil)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(objStripeError, nil)
                    }
                }
        }
	}
	class func detachSource(customer: STPCustomer, deleting card: STPCard, completion: @escaping ((STPCustomer?, QTStripeError?) -> Void)) {
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
                            let objStripeError = QTStripeError(error: error)
                            completion(nil, objStripeError)
                        } else if let objCustomer = deserializer.customer {
                            completion(objCustomer, nil)
                        } else {
                            completion(nil, nil)
                        }
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(nil, objStripeError)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(nil, objStripeError)
                    }
                }
        }
	}
	
	class func updateDefaultSource(customer: STPCustomer, new defaultCard: STPCard, completion: @escaping ((STPCustomer?, QTStripeError?) -> Void)) {
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
                            let objStripeError = QTStripeError(error: error)
                            completion(nil, objStripeError)
                        } else if let objCustomer = deserializer.customer {
                            completion(objCustomer, nil)
                        } else {
                            completion(nil, nil)
                        }
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(nil, objStripeError)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(nil, objStripeError)
                    }
                }
        }
        
	}
	
	class func removeCustomer(customerId: String, completion: @escaping (QTStripeError?) -> Void) {
        let requestString = "\(Constants.API_BASE_URL)/stripes/customers/\(customerId)"
        
        Alamofire.request(requestString, method: .get)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(objStripeError)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(objStripeError)
                    }
                }
        }
	}
	class func removeConnectAccount(accountId: String, completion: @escaping (QTStripeError?) -> Void) {
        let requestString = "\(Constants.API_BASE_URL)/stripe/accounts/\(accountId)"
        
        Alamofire.request(requestString, method: .delete)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    if let data = response.data,
                        let dicData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                        let dicError = dicData,
                        let objStripeError = Mapper<QTStripeError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(objStripeError)
                    } else {
                        let objStripeError = QTStripeError(error: error)
                        completion(objStripeError)
                    }
                }
        }
	}
}

