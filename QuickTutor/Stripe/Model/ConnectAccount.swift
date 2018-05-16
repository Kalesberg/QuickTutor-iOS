//
//  ConnectAccount.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

struct ConnectAccount: Decodable {
	
	let charges_enabled : Bool
	let payouts_enabled : Bool
	
	let created : Int
	let default_currency : String
	let details_submitted : Bool
	
	let verification : AccountVerification
	let external_accounts : ExternalAccounts
	let legal_entity : LegalEntity

}
