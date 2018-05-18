//
//  StringExtensions.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/28/17.
//  Copyright © 2017 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func containsSwearWord(swearWords: [String]) -> Bool {
        return swearWords
            .reduce(false) { $0 || self.contains($1.lowercased()) }
    }
	
	func emailRegex () -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: self)
	}
	
	func phoneRegex() -> Bool {
		let phoneRegex = "^((\\+)|(00))[0-9]{6,14}$"
		let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
		print(self)
		return phoneTest.evaluate(with: self)
	}
	
    func cleanPhoneNumber() -> String{
        let string = "+1\(self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())"
        return string
    }
	
	func formatPhoneNumber() -> String {
		let cleanPhoneNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
		let mask = "+X (XXX) XXX XXXX"
		
		var result = ""
		var index = cleanPhoneNumber.startIndex
		
		for ch in mask {
			if index == cleanPhoneNumber.endIndex {
				break
			}
			if ch == "X" {
				result.append(cleanPhoneNumber[index])
				index = cleanPhoneNumber.index(after: index)
			} else {
				result.append(ch)
			}
		}
        
		return result
	}
	
	func formatBirthdate() -> String {
		
		let dateString = self
		let oldFormat = DateFormatter()
		oldFormat.dateFormat = "dd/mm/yyyy"
		let dateFromString = oldFormat.date(from: dateString)
		
		let newFormatter = DateFormatter()
		newFormatter.dateStyle = .long
		return newFormatter.string(from: dateFromString!) as String
	}
	
	func fullNameRegex() -> Bool {
		let fullNameRegex = "[A-Za-z]+ [A-Za-z]+"
		let fullNameTest = NSPredicate(format:"SELF MATCHES %@", fullNameRegex)
		return fullNameTest.evaluate(with: self)
	}

	func zipcodeRegex() -> Bool {
		let regex = "^[0-9]{5}([- /]?[0-9]{4})?$"
		let regexTest = NSPredicate(format: "SELF MATCHES %@", regex)
		return regexTest.evaluate(with: self)
	}
	
	func cityRegex() -> Bool {
		let regex = "(?:[A-Z][a-z.-]+[ ]?)+"
		let regexTest = NSPredicate(format: "SELF MATCHES %@", regex)
		return regexTest.evaluate(with: self)
	}
	func stateRegex() -> Bool {
		let regex = "^(?:(A[KLRZ]|C[AOT]|D[CE]|FL|GA|HI|I[ADLN]|K[SY]|LA|M[ADEINOST]|N[CDEHJMVY]|O[HKR]|P[AR]|RI|S[CD]|T[NX]|UT|V[AIT]|W[AIVY]))$"
		let regexTest = NSPredicate(format: "SELF MATCHES %@", regex)
		return regexTest.evaluate(with: self)
	}
	func streetRegex() -> Bool {
		let regex = "[0-9]{1,3}.?[0-9]{0,3}[ ][a-zA-Z]{2,30}[ ][a-zA-Z]{2,15}."
		let regexTest = NSPredicate(format: "SELF MATCHES %@", regex)
		return regexTest.evaluate(with: self)
	}
	
	func policyNormailzation() {
		
		let policy = self.split(separator: "_")
		
		let latePolicy = policy[0]
		let lateFee = policy[1]
		let cancelNotice = policy[2]
		let cancelFee = policy[3]
		
	}
	//We can do more with these, add new phrases, cases, etc.
	
	func cancelNotice() -> String {
		let text : String
		
		if self != "0" {
			text = " - Cancellations: \(self) Hour Notice\n\n"
		} else {
			text = " - No Cancellation Policy.\n"
		}
		return text
	}
	func cancelFee() -> String {
		let text : String
		
		if self != "0" {
			text = "      Cancellation Fee: $\(self).00\n"
		} else {
			text = "      No Cancellation Fee.\n"
		}
		return text
	}
	func lateFee() -> String {
		let text : String
		
		if self != "0" {
			text = "      Late Fee: $\(self).00\n"
		} else {
			text = "      No Late Fee.\n"
		}
		return text
	}
	
	func formatName() -> String {
		let name = self.components(separatedBy: " ")
		return "\(name[0])  \(name[1].prefix(1))."
	}
}

extension MutableCollection {
	/// Shuffles the contents of this collection.
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			let i = index(firstUnshuffled, offsetBy: d)
			swapAt(firstUnshuffled, i)
		}
	}
}

extension Sequence {
	/// Returns an array with the contents of this sequence, shuffled.
	func shuffled() -> [Element] {
		var result = Array(self)
		result.shuffle()
		return result
	}
}
