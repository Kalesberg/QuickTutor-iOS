//
//  ConnectAccount.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

struct ConnectAccount: Decodable {
	
	let data : [Data]
	
	struct Data : Decodable {
		let id : String
		let bank_name : String?
		let last4 : String?
		let status : String
		let account_holder_name : String?
		let default_for_currency : Bool?
	}
}
