//
//  ExternalAccounts.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

struct ExternalAccounts : Decodable {
	let total_count : Int?
	let data : [ExternalAccountsData]
	
}
struct ExternalAccountsData : Decodable {
	let id : String
	let bank_name : String?
	let last4 : String
	let status : String
	let account_holder_name : String
	let default_for_currency : Bool
}
