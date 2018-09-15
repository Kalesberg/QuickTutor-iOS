//
//  exm.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class YourClass: UIViewController {

	//It is also a good idea to set up a NoPasteTextField class to deny the user the ability to paste anything into this textfield.
	let textField : UITextField = {
		let textField = UITextField()
		// These are 'long dashes' you can replace them with whatever you would like.
		// These look best IMO.
		textField.text = "——————" //No spaces needed!
		textField.textColor = .black
		textField.textAlignment = .center
		return textField
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		textField.delegate = self
		//This sets the spacing or 'Kern' of the textfield. Adjust the value: 10.0 and the fontSize to get the desired output.
		textField.defaultTextAttributes.updateValue(10.0, forKey: NSAttributedStringKey.kern.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension YourClass : UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		//get the current text of the textField.
		guard let text = textField.text else { return false }
		
		//handle backspace event.
		if string == "" {
			guard let indexToReplace = text.index(text.startIndex, offsetBy: range.location, limitedBy: text.endIndex) else { return false }
			textField.text?.remove(at: indexToReplace)
			textField.text?.insert("—", at: indexToReplace)
			//adjust position of the cursor
			if let newPostion = textField.position(from: textField.beginningOfDocument, offset: range.location) {
				textField.selectedTextRange = textField.textRange(from: newPostion, to: newPostion)
				return false
			}
		}
		//handle character entered event.
		if range.location + 1 <= text.count,
			let end = text.index(text.startIndex, offsetBy: range.location + 1, limitedBy: text.endIndex),
			let start = text.index(text.startIndex, offsetBy: range.location, limitedBy: text.endIndex) {
			textField.text = textField.text?.replacingOccurrences(of: "—", with: string, options: .caseInsensitive, range: Range(uncheckedBounds: (lower: start, upper: end)))
		}
		//adjust cursor position.
		if range.location + 1 < text.count {
			if let newPosition = textField.position(from: textField.beginningOfDocument, offset: range.location + 1){
				textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
			}
		}
		return false
	}
	//make sure to start at the begining of the textField.
	func textFieldDidBeginEditing(_ textField: UITextField) {
		let newPosition = textField.beginningOfDocument
		textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
	}
}
