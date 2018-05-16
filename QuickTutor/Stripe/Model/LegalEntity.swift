//
//  LegalEntity.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

struct LegalEntity : Decodable {
	let business_tax_id_provided : Bool
	
	let address : LegalEntityAddress
	let dob  : LegalEntityDOB
	let verification : LegalEntityVerification
}

struct LegalEntityDOB : Decodable {
	let day : Int
	let month : Int
	let year : Int
}

struct LegalEntityAddress : Decodable {
	let city : String
	let country : String
	let line1 : String
	let postal_code : String
	let state : String
}

struct LegalEntityVerification : Decodable {
	let details : String?
	let details_code: String?
	let document : String?
	let status : String
}
