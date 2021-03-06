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
	func fullNameRegex() -> Bool {
		let fullNameRegex = "[A-Za-z]+ [A-Za-z]+"
		let fullNameTest = NSPredicate(format:"SELF MATCHES %@", fullNameRegex)
		return fullNameTest.evaluate(with: self)
	}
	func fullNamePaymentRegex() -> Bool {
		let fullNameRegex = "[a-zA-z]+ [a-zA-z]+ [a-zA-z]+"
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
		let regex = "\\d+[ ](?:[A-Za-z0-9.-]+[ ]?)+(?:Avenue|Lane|Road|Boulevard|Drive|Street|Ave||Dr|Rd|Blvd|Ln|St)\\.?"
		let regexTest = NSPredicate(format: "SELF MATCHES %@", regex)
		return regexTest.evaluate(with: self)
	}
	
	func cancelNotice() -> String {
		let text : String
		
		if self != "0" {
			text = "Cancellation Policy: \(self) Hour Notice\n"
		} else {
			text = "No Cancellation Policy.\n"
		}
		return text
	}
    
    func cancelNoticeNew() -> NSAttributedString {
        var text : NSMutableAttributedString
        
        let blackAttributes = [NSAttributedString.Key.font: Fonts.createBlackSize(14), NSAttributedString.Key.foregroundColor: Colors.grayText80]
        let normalAttributes = [NSAttributedString.Key.font: Fonts.createSize(14), NSAttributedString.Key.foregroundColor: Colors.grayText80]
        
        if self != "0" {
            text = NSMutableAttributedString(string: "Cancellation Policy:", attributes: blackAttributes)
            text.append(NSAttributedString(string: " \(self) Hour Notice\n", attributes: normalAttributes))
        } else {
            text = NSMutableAttributedString(string: "No Cancellation Policy.", attributes: normalAttributes)
        }
        return text
    }
    
	func lateNotice() -> String {
		let text : String
		
		if self != "0" {
			text = "Late Policy: \(self) Minute Notice\n"
		} else {
			text = "No Late Policy.\n"
		}
		return text
	}
    
    func lateNoticeNew() -> NSAttributedString {
        var text : NSMutableAttributedString
        
        let blackAttributes = [NSAttributedString.Key.font: Fonts.createBlackSize(14), NSAttributedString.Key.foregroundColor: Colors.grayText80]
        let normalAttributes = [NSAttributedString.Key.font: Fonts.createSize(14), NSAttributedString.Key.foregroundColor: Colors.grayText80]
        
        if self != "0" {
            text = NSMutableAttributedString(string: "Late Policy:", attributes: blackAttributes)
            text.append(NSAttributedString(string: "  \(self) Minute Notice", attributes: normalAttributes))
        } else {
            text = NSMutableAttributedString(string: "No Late Policy.", attributes: normalAttributes)
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
	
	func getIntIndex(of char: Character) -> Int? {
		if let idx = self.firstIndex(of: char) {
			return self.distance(from: startIndex, to: idx)
		}
		return nil
	}
	func removeCharacters(from forbiddenChars: CharacterSet) -> String {
		let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
		return String(String.UnicodeScalarView(passed))
	}
	func removeCharacters(from: String) -> String {
		return removeCharacters(from: CharacterSet(charactersIn: from))
	}
	mutating func removeForbiddenCharsForDB() -> String {
		return self.replacingOccurrences(of: ".", with: "<").replacingOccurrences(of: "#", with: ">").replacingOccurrences(of: "/", with: "_")
	}
	mutating func replaceForbiddenChars() -> String {
		return self.replacingOccurrences(of: "<", with: ".").replacingOccurrences(of: ">", with: "#").replacingOccurrences(of: "_", with: "/")
	}

	func toBirthdatePrettyFormat() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM/yyyy"
		if let date = dateFormatter.date(from: self) {
			print("DATE: ", date)
			dateFormatter.dateFormat = "MMMM d'\(date.daySuffix())' yyyy"
			return dateFormatter.string(from: date)
		}
		return self
	}
    
    func getStringWidth(font: UIFont) -> CGFloat {
        return self.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0.0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).width
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

extension MutableCollection {
	/// Shuffles the contents of this collection.
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
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

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: CountableRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: CountablePartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}
