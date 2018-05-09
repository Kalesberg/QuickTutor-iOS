//
//  BalanceTransaction.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

struct BalanceTransaction: Decodable {
	
	let data : [Data]
	
	struct Data : Decodable {
		let id : String?
		let amount : Int?
		let created : Int?
		let description : String?
		let fee : Int?
		let net : Int?
		let status : String?
	}
}
