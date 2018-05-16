//
//  AccountVerification.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

struct AccountVerification : Decodable {
	let disabled_reason : String?
	let due_by : Int?
	let fields_needed : [String]
	
}
