//
//  ArrayExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

extension Array where Element: Numeric {
	/// Returns the total sum of all elements in the array
	var total: Element { return reduce(0, +) }
}

extension Array where Element: FloatingPoint {
	/// Returns the average of all elements in the array
	var average: Element {
		return isEmpty ? 0 : total / Element(count)
	}
}
